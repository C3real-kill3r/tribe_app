# Tribe App - Comprehensive Backend Implementation Plan

## Executive Summary

This document provides a complete backend architecture and implementation plan for the Tribe social accountability app using **FastAPI** and **PostgreSQL**. The system is designed for scalability, efficiency, and speed, supporting features including authentication, real-time chat, AI coaching, goal tracking, memory/story sharing, social interactions, and comprehensive settings management.

---

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [System Architecture](#system-architecture)
3. [Database Schema Design](#database-schema-design)
4. [API Endpoints Specification](#api-endpoints-specification)
5. [Real-Time Features](#real-time-features)
6. [AI Integration](#ai-integration)
7. [File Storage Strategy](#file-storage-strategy)
8. [Security & Authentication](#security--authentication)
9. [Performance Optimization](#performance-optimization)
10. [Deployment Architecture](#deployment-architecture)

---

## 1. Technology Stack

### Core Framework
- **FastAPI** (Python 3.11+) - High-performance async web framework
- **PostgreSQL 15+** - Primary relational database
- **Redis** - Caching and real-time features
- **SQLAlchemy 2.0** - ORM with async support
- **Alembic** - Database migrations

### Additional Services
- **Celery** - Background task processing
- **WebSockets** - Real-time chat and notifications
- **AWS S3 / CloudFlare R2** - Media storage
- **OpenAI API** - AI Coach integration
- **Firebase Cloud Messaging** - Push notifications
- **Elasticsearch** (Optional) - Full-text search

### Development Tools
- **Pydantic v2** - Data validation
- **pytest** - Testing
- **Docker** - Containerization
- **nginx** - Reverse proxy
- **Gunicorn/Uvicorn** - ASGI server

---

## 2. System Architecture

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │
       ├──── HTTP/REST ────┐
       ├──── WebSocket ────┤
       │                   ▼
┌──────────────────────────────────┐
│       FastAPI Application        │
│  ┌────────────┐  ┌─────────────┐ │
│  │   Auth     │  │  WebSocket  │ │
│  │  Middleware│  │   Manager   │ │
│  └────────────┘  └─────────────┘ │
└──────────┬───────────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────┐   ┌──────────┐
│ Redis  │   │Postgres│   │ S3/Media │
│ Cache  │   │   DB   │   │ Storage  │
└────────┘   └────────┘   └──────────┘
    │
┌───▼────────┐
│   Celery   │
│  Workers   │
└────────────┘
```

---

## 3. Database Schema Design

### 3.1 Users & Authentication

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    bio TEXT,
    profile_image_url TEXT,
    cover_image_url TEXT,
    
    -- Privacy settings
    profile_visibility VARCHAR(20) DEFAULT 'friends_only' CHECK (profile_visibility IN ('everyone', 'friends_only', 'private')),
    online_status_visible BOOLEAN DEFAULT TRUE,
    appear_in_suggestions BOOLEAN DEFAULT TRUE,
    
    -- Stats
    goals_achieved INTEGER DEFAULT 0,
    photos_shared INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_seen_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_users_email (email),
    INDEX idx_users_username (username),
    INDEX idx_users_last_seen (last_seen_at)
);

-- Refresh tokens for JWT
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    device_info JSONB,
    ip_address INET,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_refresh_tokens_user (user_id),
    INDEX idx_refresh_tokens_hash (token_hash)
);

-- Password reset tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_password_reset_user (user_id)
);

-- Email verification tokens
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3.2 Friendships & Social

```sql
-- Friendships
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'accepted', 'blocked')),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id),
    
    INDEX idx_friendships_user (user_id, status),
    INDEX idx_friendships_friend (friend_id, status)
);

-- Friend suggestions (for discovery)
CREATE TABLE friend_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    suggested_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score FLOAT DEFAULT 0,
    reason VARCHAR(100), -- 'mutual_friends', 'common_goals', etc.
    dismissed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, suggested_user_id),
    INDEX idx_suggestions_user (user_id, dismissed)
);

-- Accountability partners
CREATE TABLE accountability_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paused', 'ended')),
    check_in_frequency VARCHAR(20), -- 'daily', 'weekly', etc.
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(user_id, partner_id),
    INDEX idx_accountability_user (user_id, status)
);
```

### 3.3 Goals & Accountability

```sql
-- Goals
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50), -- 'savings', 'fitness', 'education', etc.
    goal_type VARCHAR(20) NOT NULL CHECK (goal_type IN ('individual', 'group')),
    
    -- Target settings
    target_type VARCHAR(20) CHECK (target_type IN ('amount', 'date', 'milestone')),
    target_amount DECIMAL(12, 2),
    target_currency VARCHAR(3) DEFAULT 'USD',
    target_date DATE,
    
    -- Progress
    current_amount DECIMAL(12, 2) DEFAULT 0,
    progress_percentage FLOAT DEFAULT 0,
    
    -- Media
    image_url TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
    is_public BOOLEAN DEFAULT FALSE,
    
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_goals_creator (creator_id, status),
    INDEX idx_goals_status (status),
    INDEX idx_goals_category (category)
);

-- Goal participants
CREATE TABLE goal_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('creator', 'member', 'supporter')),
    contribution_amount DECIMAL(12, 2) DEFAULT 0,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(goal_id, user_id),
    INDEX idx_goal_participants_goal (goal_id),
    INDEX idx_goal_participants_user (user_id)
);

-- Goal contributions/activities
CREATE TABLE goal_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    note TEXT,
    contribution_type VARCHAR(20) DEFAULT 'monetary' CHECK (contribution_type IN ('monetary', 'milestone', 'checkin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_contributions_goal (goal_id, created_at DESC),
    INDEX idx_contributions_user (user_id, created_at DESC)
);

-- Goal milestones
CREATE TABLE goal_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    target_value DECIMAL(12, 2),
    achieved BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMP WITH TIME ZONE,
    achieved_by UUID REFERENCES users(id),
    order_index INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_milestones_goal (goal_id, order_index)
);

-- Goal reminders
CREATE TABLE goal_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reminder_type VARCHAR(20) CHECK (reminder_type IN ('daily', 'weekly', 'custom')),
    reminder_time TIME,
    reminder_days INTEGER[], -- Array of day numbers (0-6)
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_reminders_user (user_id, is_active)
);
```

### 3.4 Memories, Stories & Posts

```sql
-- Posts (memories/photos)
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    caption TEXT,
    post_type VARCHAR(20) DEFAULT 'photo' CHECK (post_type IN ('photo', 'video', 'text')),
    
    -- Associated goal (optional)
    goal_id UUID REFERENCES goals(id) ON DELETE SET NULL,
    
    -- Media
    media_url TEXT NOT NULL,
    media_thumbnail_url TEXT,
    media_width INTEGER,
    media_height INTEGER,
    
    -- Visibility
    visibility VARCHAR(20) DEFAULT 'friends' CHECK (visibility IN ('public', 'friends', 'private')),
    
    -- Stats
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    
    -- Status
    is_archived BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_posts_user (user_id, created_at DESC),
    INDEX idx_posts_goal (goal_id, created_at DESC),
    INDEX idx_posts_created (created_at DESC)
);

-- Stories (24-hour ephemeral content)
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_thumbnail_url TEXT,
    media_type VARCHAR(20) CHECK (media_type IN ('image', 'video')),
    duration INTEGER DEFAULT 5, -- seconds
    
    -- Stats
    views_count INTEGER DEFAULT 0,
    
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_stories_user (user_id, created_at DESC),
    INDEX idx_stories_expires (expires_at)
);

-- Story views
CREATE TABLE story_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    viewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(story_id, viewer_id),
    INDEX idx_story_views_story (story_id, viewed_at DESC)
);

-- Post likes
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(post_id, user_id),
    INDEX idx_likes_post (post_id, created_at DESC),
    INDEX idx_likes_user (user_id, created_at DESC)
);

-- Post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE, -- For nested replies
    
    -- Stats
    likes_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_comments_post (post_id, created_at ASC),
    INDEX idx_comments_user (user_id, created_at DESC),
    INDEX idx_comments_parent (parent_comment_id)
);

-- Comment likes
CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID NOT NULL REFERENCES post_comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(comment_id, user_id),
    INDEX idx_comment_likes_comment (comment_id)
);
```

### 3.5 Messaging & Chat

```sql
-- Conversations (both 1-on-1 and groups)
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_type VARCHAR(20) NOT NULL CHECK (conversation_type IN ('direct', 'group', 'ai_coach')),
    name VARCHAR(255), -- For group chats
    image_url TEXT, -- For group chats
    
    -- Group settings
    is_group BOOLEAN DEFAULT FALSE,
    
    -- Last activity
    last_message_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_conversations_last_message (last_message_at DESC)
);

-- Conversation participants
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    
    -- Read status
    last_read_at TIMESTAMP WITH TIME ZONE,
    unread_count INTEGER DEFAULT 0,
    
    -- Settings
    is_muted BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(conversation_id, user_id),
    INDEX idx_participants_conversation (conversation_id),
    INDEX idx_participants_user (user_id, is_archived)
);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL for system/AI messages
    
    -- Content
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video', 'audio', 'file', 'system', 'goal_update')),
    
    -- Media attachments
    media_url TEXT,
    media_thumbnail_url TEXT,
    
    -- Special messages
    metadata JSONB, -- For system messages, goal updates, etc.
    
    -- Reply/Thread
    reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    
    -- Status
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_messages_conversation (conversation_id, created_at DESC),
    INDEX idx_messages_sender (sender_id, created_at DESC)
);

-- Message read receipts
CREATE TABLE message_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(message_id, user_id),
    INDEX idx_message_reads_message (message_id),
    INDEX idx_message_reads_user (user_id)
);

-- AI Coach conversations (specialized tracking)
CREATE TABLE ai_coach_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    
    -- Context
    context_summary TEXT,
    user_goals JSONB, -- Snapshot of user goals for context
    
    -- Usage tracking
    message_count INTEGER DEFAULT 0,
    tokens_used INTEGER DEFAULT 0,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_interaction_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_ai_sessions_user (user_id, last_interaction_at DESC)
);
```

### 3.6 Notifications

```sql
-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    notification_type VARCHAR(50) NOT NULL, -- 'goal_completed', 'friend_request', 'post_like', 'comment', etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related entities
    related_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    related_goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    related_post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    related_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    
    -- Media
    image_url TEXT,
    icon_type VARCHAR(50),
    icon_color VARCHAR(20),
    
    -- Navigation
    action_url TEXT, -- Deep link for app navigation
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Push notification
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_notifications_user (user_id, is_read, created_at DESC),
    INDEX idx_notifications_type (notification_type)
);

-- Notification preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Push notifications
    push_enabled BOOLEAN DEFAULT TRUE,
    
    -- Email notifications
    email_enabled BOOLEAN DEFAULT FALSE,
    
    -- Notification types
    goal_reminders BOOLEAN DEFAULT TRUE,
    friend_requests BOOLEAN DEFAULT TRUE,
    messages BOOLEAN DEFAULT TRUE,
    achievements BOOLEAN DEFAULT TRUE,
    post_likes BOOLEAN DEFAULT TRUE,
    post_comments BOOLEAN DEFAULT TRUE,
    goal_updates BOOLEAN DEFAULT TRUE,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Push notification tokens
CREATE TABLE push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type VARCHAR(20) CHECK (device_type IN ('ios', 'android', 'web')),
    device_id VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, token),
    INDEX idx_push_tokens_user (user_id, is_active)
);
```

### 3.7 User Settings & Preferences

```sql
-- User settings
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Privacy settings
    who_can_send_friend_requests VARCHAR(20) DEFAULT 'friends_of_friends' 
        CHECK (who_can_send_friend_requests IN ('everyone', 'friends_of_friends', 'no_one')),
    who_can_send_messages VARCHAR(20) DEFAULT 'friends_only' 
        CHECK (who_can_send_messages IN ('everyone', 'friends_only')),
    share_activity_with_friends BOOLEAN DEFAULT TRUE,
    
    -- Appearance settings
    theme_mode VARCHAR(20) DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
    accent_color VARCHAR(7) DEFAULT '#FF6B6B', -- Hex color
    font_size_multiplier DECIMAL(3, 2) DEFAULT 1.0,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blocked users
CREATE TABLE blocked_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    blocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(blocker_id, blocked_id),
    INDEX idx_blocked_users_blocker (blocker_id)
);
```

### 3.8 Activity & Analytics

```sql
-- User activity log
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- 'login', 'post_created', 'goal_completed', etc.
    description TEXT,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_activities_user (user_id, created_at DESC),
    INDEX idx_activities_type (activity_type, created_at DESC)
);

-- User achievements/badges
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url TEXT,
    category VARCHAR(50),
    points INTEGER DEFAULT 0,
    
    -- Criteria
    criteria JSONB, -- Rules for earning the achievement
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, achievement_id),
    INDEX idx_user_achievements_user (user_id, earned_at DESC)
);

-- Feed/timeline entries
CREATE TABLE feed_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Feed owner
    
    -- Source
    source_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    entry_type VARCHAR(50) NOT NULL, -- 'post', 'goal_update', 'achievement', etc.
    
    -- Related entities
    related_post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    related_goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Ranking/sorting
    score FLOAT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_feed_entries_user (user_id, created_at DESC),
    INDEX idx_feed_entries_score (user_id, score DESC)
);
```

### 3.9 Tribes/Groups (Future Feature)

```sql
-- Tribes (groups with shared goals)
CREATE TABLE tribes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    cover_image_url TEXT,
    
    -- Settings
    is_private BOOLEAN DEFAULT FALSE,
    require_approval BOOLEAN DEFAULT TRUE,
    
    -- Stats
    member_count INTEGER DEFAULT 0,
    
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_tribes_created_by (created_by)
);

-- Tribe members
CREATE TABLE tribe_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tribe_id UUID NOT NULL REFERENCES tribes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(tribe_id, user_id),
    INDEX idx_tribe_members_tribe (tribe_id),
    INDEX idx_tribe_members_user (user_id)
);

-- Tribe invitations
CREATE TABLE tribe_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tribe_id UUID NOT NULL REFERENCES tribes(id) ON DELETE CASCADE,
    inviter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_tribe_invitations_invitee (invitee_id, status)
);
```

---

## 4. API Endpoints Specification

### 4.1 Authentication Endpoints

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/verify-email
POST   /api/v1/auth/resend-verification
GET    /api/v1/auth/me
```

#### POST /api/v1/auth/register

**Request:**
```json
{
  "email": "brian.okuku@example.com",
  "username": "brianokuku",
  "full_name": "Brian Okuku",
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "email": "brian.okuku@example.com",
    "username": "brianokuku",
    "full_name": "Brian Okuku",
    "profile_image_url": null,
    "email_verified": false,
    "created_at": "2024-01-01T00:00:00Z"
  },
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "token_type": "bearer",
  "expires_in": 3600
}
```

#### POST /api/v1/auth/login

**Request:**
```json
{
  "email": "brian.okuku@example.com",
  "password": "SecurePass123!",
  "device_info": {
    "device_type": "ios",
    "device_id": "device_uuid",
    "app_version": "1.0.0"
  }
}
```

**Response (200):**
```json
{
  "user": {
    "id": "uuid",
    "email": "brian.okuku@example.com",
    "username": "brianokuku",
    "full_name": "Brian Okuku",
    "bio": "Chasing goals and making memories...",
    "profile_image_url": "https://cdn.example.com/...",
    "cover_image_url": "https://cdn.example.com/...",
    "goals_achieved": 5,
    "photos_shared": 128,
    "email_verified": true,
    "created_at": "2024-01-01T00:00:00Z"
  },
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "token_type": "bearer",
  "expires_in": 3600
}
```

#### POST /api/v1/auth/refresh

**Request:**
```json
{
  "refresh_token": "refresh_token_string"
}
```

**Response (200):**
```json
{
  "access_token": "new_jwt_token",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### 4.2 User Profile Endpoints

```
GET    /api/v1/users/me
PUT    /api/v1/users/me
PATCH  /api/v1/users/me/profile-image
PATCH  /api/v1/users/me/cover-image
GET    /api/v1/users/:userId
GET    /api/v1/users/:userId/stats
GET    /api/v1/users/:userId/goals
GET    /api/v1/users/:userId/posts
GET    /api/v1/users/:userId/friends
```

#### GET /api/v1/users/me

**Response (200):**
```json
{
  "id": "uuid",
  "email": "brian.okuku@example.com",
  "username": "brianokuku",
  "full_name": "Brian Okuku",
  "bio": "Chasing goals and making memories with my favorite people. ✨",
  "profile_image_url": "https://cdn.example.com/...",
  "cover_image_url": "https://cdn.example.com/...",
  "goals_achieved": 5,
  "photos_shared": 128,
  "email_verified": true,
  "is_active": true,
  "last_seen_at": "2024-01-01T12:00:00Z",
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### PUT /api/v1/users/me

**Request:**
```json
{
  "full_name": "Brian Okuku",
  "username": "brianokuku",
  "bio": "Updated bio text",
  "email": "newemail@example.com"
}
```

**Response (200):**
```json
{
  "id": "uuid",
  "email": "newemail@example.com",
  "username": "brianokuku",
  "full_name": "Brian Okuku",
  "bio": "Updated bio text",
  "profile_image_url": "https://cdn.example.com/...",
  "email_verified": false,
  "updated_at": "2024-01-01T12:00:00Z"
}
```

#### PATCH /api/v1/users/me/profile-image

**Request (multipart/form-data):**
```
image: [file]
```

**Response (200):**
```json
{
  "profile_image_url": "https://cdn.example.com/users/uuid/profile.jpg",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

### 4.3 Friends & Social Endpoints

```
GET    /api/v1/friends
GET    /api/v1/friends/requests
POST   /api/v1/friends/requests
PUT    /api/v1/friends/requests/:requestId/accept
PUT    /api/v1/friends/requests/:requestId/decline
DELETE /api/v1/friends/:friendId
GET    /api/v1/friends/suggestions
POST   /api/v1/friends/suggestions/:userId/dismiss
GET    /api/v1/friends/search?q=query
GET    /api/v1/friends/online
```

#### GET /api/v1/friends

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `sort` (options: 'recent', 'alphabetical', 'active')

**Response (200):**
```json
{
  "friends": [
    {
      "id": "uuid",
      "username": "cedricochola",
      "full_name": "Cedric Ochola",
      "profile_image_url": "https://cdn.example.com/...",
      "is_online": true,
      "last_seen_at": "2024-01-01T12:00:00Z",
      "friendship_since": "2023-06-15T10:00:00Z",
      "mutual_friends_count": 8
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

#### POST /api/v1/friends/requests

**Request:**
```json
{
  "user_id": "uuid"
}
```

**Response (201):**
```json
{
  "id": "request_uuid",
  "user_id": "sender_uuid",
  "friend_id": "receiver_uuid",
  "status": "pending",
  "requested_at": "2024-01-01T12:00:00Z"
}
```

#### GET /api/v1/friends/suggestions

**Response (200):**
```json
{
  "suggestions": [
    {
      "user": {
        "id": "uuid",
        "username": "derrickjuma",
        "full_name": "Derrick Juma",
        "profile_image_url": "https://cdn.example.com/..."
      },
      "reason": "mutual_friends",
      "mutual_friends_count": 12,
      "common_goals": 3
    }
  ]
}
```

### 4.4 Goals Endpoints

```
GET    /api/v1/goals
POST   /api/v1/goals
GET    /api/v1/goals/:goalId
PUT    /api/v1/goals/:goalId
DELETE /api/v1/goals/:goalId
POST   /api/v1/goals/:goalId/participants
DELETE /api/v1/goals/:goalId/participants/:userId
POST   /api/v1/goals/:goalId/contributions
GET    /api/v1/goals/:goalId/contributions
POST   /api/v1/goals/:goalId/milestones
PUT    /api/v1/goals/:goalId/milestones/:milestoneId
DELETE /api/v1/goals/:goalId/milestones/:milestoneId
POST   /api/v1/goals/:goalId/complete
GET    /api/v1/goals/feed
```

#### POST /api/v1/goals

**Request:**
```json
{
  "title": "Trip to Costa Rica 🌴",
  "description": "Save money for our dream vacation",
  "category": "travel",
  "goal_type": "group",
  "target_type": "amount",
  "target_amount": 3000.00,
  "target_currency": "USD",
  "target_date": "2024-06-30",
  "is_public": false,
  "image_url": "https://cdn.example.com/...",
  "participant_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Response (201):**
```json
{
  "id": "goal_uuid",
  "creator_id": "user_uuid",
  "title": "Trip to Costa Rica 🌴",
  "description": "Save money for our dream vacation",
  "category": "travel",
  "goal_type": "group",
  "target_type": "amount",
  "target_amount": 3000.00,
  "target_currency": "USD",
  "target_date": "2024-06-30",
  "current_amount": 0,
  "progress_percentage": 0,
  "image_url": "https://cdn.example.com/...",
  "status": "active",
  "is_public": false,
  "participants": [
    {
      "user_id": "uuid1",
      "username": "brianokuku",
      "full_name": "Brian Okuku",
      "profile_image_url": "https://cdn.example.com/...",
      "role": "creator",
      "contribution_amount": 0
    }
  ],
  "created_at": "2024-01-01T12:00:00Z"
}
```

#### GET /api/v1/goals

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `status` (options: 'active', 'completed', 'all')
- `category` (filter by category)
- `type` (options: 'individual', 'group', 'all')

**Response (200):**
```json
{
  "goals": [
    {
      "id": "uuid",
      "title": "Trip to Costa Rica 🌴",
      "category": "travel",
      "goal_type": "group",
      "target_amount": 3000.00,
      "current_amount": 1950.00,
      "progress_percentage": 65,
      "target_date": "2024-06-30",
      "days_remaining": 45,
      "image_url": "https://cdn.example.com/...",
      "participants_count": 4,
      "participants_preview": [
        {
          "user_id": "uuid",
          "profile_image_url": "https://cdn.example.com/..."
        }
      ],
      "status": "active",
      "created_at": "2024-01-01T12:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "total_pages": 1
  }
}
```

#### POST /api/v1/goals/:goalId/contributions

**Request:**
```json
{
  "amount": 150.00,
  "note": "Contributing from my savings!",
  "contribution_type": "monetary"
}
```

**Response (201):**
```json
{
  "id": "contribution_uuid",
  "goal_id": "goal_uuid",
  "user_id": "user_uuid",
  "amount": 150.00,
  "note": "Contributing from my savings!",
  "contribution_type": "monetary",
  "created_at": "2024-01-01T12:00:00Z",
  "goal_progress": {
    "current_amount": 2100.00,
    "progress_percentage": 70
  }
}
```

### 4.5 Posts & Memories Endpoints

```
GET    /api/v1/posts
POST   /api/v1/posts
GET    /api/v1/posts/:postId
PUT    /api/v1/posts/:postId
DELETE /api/v1/posts/:postId
POST   /api/v1/posts/:postId/like
DELETE /api/v1/posts/:postId/like
GET    /api/v1/posts/:postId/likes
POST   /api/v1/posts/:postId/comments
GET    /api/v1/posts/:postId/comments
PUT    /api/v1/posts/comments/:commentId
DELETE /api/v1/posts/comments/:commentId
GET    /api/v1/feed
```

#### POST /api/v1/posts

**Request (multipart/form-data):**
```
image: [file]
caption: "First training session in the books!"
goal_id: "goal_uuid" (optional)
visibility: "friends"
```

**Response (201):**
```json
{
  "id": "post_uuid",
  "user": {
    "id": "user_uuid",
    "username": "alvinamwata",
    "full_name": "Alvin Amwata",
    "profile_image_url": "https://cdn.example.com/..."
  },
  "caption": "First training session in the books!",
  "media_url": "https://cdn.example.com/posts/...",
  "media_thumbnail_url": "https://cdn.example.com/posts/.../thumb.jpg",
  "post_type": "photo",
  "goal": {
    "id": "goal_uuid",
    "title": "Run a 5K"
  },
  "visibility": "friends",
  "likes_count": 0,
  "comments_count": 0,
  "created_at": "2024-01-01T12:00:00Z"
}
```

#### GET /api/v1/posts/:postId

**Response (200):**
```json
{
  "id": "post_uuid",
  "user": {
    "id": "user_uuid",
    "username": "alvinamwata",
    "full_name": "Alvin Amwata",
    "profile_image_url": "https://cdn.example.com/..."
  },
  "caption": "First training session in the books!",
  "media_url": "https://cdn.example.com/...",
  "media_thumbnail_url": "https://cdn.example.com/.../thumb.jpg",
  "post_type": "photo",
  "goal": {
    "id": "goal_uuid",
    "title": "Run a 5K"
  },
  "likes_count": 12,
  "comments_count": 3,
  "is_liked_by_me": false,
  "created_at": "2024-01-01T10:00:00Z",
  "time_ago": "2 hours ago"
}
```

#### POST /api/v1/posts/:postId/comments

**Request:**
```json
{
  "content": "Yesss! So proud of you! Way to start strong. 💪",
  "parent_comment_id": null
}
```

**Response (201):**
```json
{
  "id": "comment_uuid",
  "post_id": "post_uuid",
  "user": {
    "id": "user_uuid",
    "username": "clariegor",
    "full_name": "Clarie Gor",
    "profile_image_url": "https://cdn.example.com/..."
  },
  "content": "Yesss! So proud of you! Way to start strong. 💪",
  "parent_comment_id": null,
  "likes_count": 0,
  "created_at": "2024-01-01T12:00:00Z"
}
```

#### GET /api/v1/feed

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `feed_type` (options: 'friends', 'discover', 'following')

**Response (200):**
```json
{
  "posts": [
    {
      "id": "post_uuid",
      "user": {
        "id": "user_uuid",
        "username": "alvinamwata",
        "full_name": "Alvin Amwata",
        "profile_image_url": "https://cdn.example.com/..."
      },
      "caption": "First training session in the books!",
      "media_url": "https://cdn.example.com/...",
      "media_thumbnail_url": "https://cdn.example.com/.../thumb.jpg",
      "goal": {
        "id": "goal_uuid",
        "title": "Run a 5K"
      },
      "likes_count": 12,
      "comments_count": 3,
      "is_liked_by_me": false,
      "time_ago": "2 hours ago",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "has_more": true
  }
}
```

### 4.6 Stories Endpoints

```
GET    /api/v1/stories
POST   /api/v1/stories
GET    /api/v1/stories/:storyId
DELETE /api/v1/stories/:storyId
POST   /api/v1/stories/:storyId/view
GET    /api/v1/stories/:storyId/views
```

#### GET /api/v1/stories

**Response (200):**
```json
{
  "stories": [
    {
      "user": {
        "id": "user_uuid",
        "username": "clariegor",
        "full_name": "Clarie Gor",
        "profile_image_url": "https://cdn.example.com/..."
      },
      "stories": [
        {
          "id": "story_uuid",
          "media_url": "https://cdn.example.com/...",
          "media_thumbnail_url": "https://cdn.example.com/.../thumb.jpg",
          "media_type": "image",
          "duration": 5,
          "views_count": 45,
          "viewed_by_me": false,
          "expires_at": "2024-01-02T12:00:00Z",
          "created_at": "2024-01-01T12:00:00Z"
        }
      ],
      "has_unviewed": true
    }
  ]
}
```

#### POST /api/v1/stories

**Request (multipart/form-data):**
```
media: [file]
media_type: "image"
duration: 5
```

**Response (201):**
```json
{
  "id": "story_uuid",
  "user_id": "user_uuid",
  "media_url": "https://cdn.example.com/...",
  "media_thumbnail_url": "https://cdn.example.com/.../thumb.jpg",
  "media_type": "image",
  "duration": 5,
  "views_count": 0,
  "expires_at": "2024-01-02T12:00:00Z",
  "created_at": "2024-01-01T12:00:00Z"
}
```

### 4.7 Chat & Messaging Endpoints

```
GET    /api/v1/conversations
POST   /api/v1/conversations
GET    /api/v1/conversations/:conversationId
DELETE /api/v1/conversations/:conversationId
GET    /api/v1/conversations/:conversationId/messages
POST   /api/v1/conversations/:conversationId/messages
PUT    /api/v1/conversations/:conversationId/messages/:messageId
DELETE /api/v1/conversations/:conversationId/messages/:messageId
POST   /api/v1/conversations/:conversationId/read
POST   /api/v1/conversations/:conversationId/participants
DELETE /api/v1/conversations/:conversationId/participants/:userId
```

#### GET /api/v1/conversations

**Response (200):**
```json
{
  "conversations": [
    {
      "id": "conversation_uuid",
      "conversation_type": "group",
      "name": "Marathon Crew",
      "image_url": "https://cdn.example.com/...",
      "is_group": true,
      "participants": [
        {
          "user_id": "uuid",
          "username": "brianonyango",
          "profile_image_url": "https://cdn.example.com/..."
        }
      ],
      "participants_count": 6,
      "last_message": {
        "id": "message_uuid",
        "sender": {
          "username": "brianonyango",
          "full_name": "Brian Onyango"
        },
        "content": "Check out the view from my run...",
        "message_type": "text",
        "created_at": "2024-01-01T10:45:00Z"
      },
      "unread_count": 3,
      "is_muted": false,
      "last_message_at": "2024-01-01T10:45:00Z"
    },
    {
      "id": "ai_coach_uuid",
      "conversation_type": "ai_coach",
      "name": "Tribe Coach",
      "image_url": null,
      "is_group": false,
      "last_message": {
        "content": "Hi! I'm your Tribe Coach. How can I help you today?",
        "message_type": "text",
        "created_at": "2024-01-01T09:00:00Z"
      },
      "unread_count": 0,
      "last_message_at": "2024-01-01T09:00:00Z"
    }
  ]
}
```

#### POST /api/v1/conversations

**Request:**
```json
{
  "conversation_type": "direct",
  "participant_ids": ["user_uuid"]
}
```

**Response (201):**
```json
{
  "id": "conversation_uuid",
  "conversation_type": "direct",
  "participants": [
    {
      "user_id": "user_uuid",
      "username": "derrickjuma",
      "full_name": "Derrick Juma",
      "profile_image_url": "https://cdn.example.com/..."
    }
  ],
  "created_at": "2024-01-01T12:00:00Z"
}
```

#### GET /api/v1/conversations/:conversationId/messages

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 50)
- `before` (message_id for pagination)

**Response (200):**
```json
{
  "messages": [
    {
      "id": "message_uuid",
      "conversation_id": "conversation_uuid",
      "sender": {
        "id": "user_uuid",
        "username": "brianonyango",
        "full_name": "Brian Onyango",
        "profile_image_url": "https://cdn.example.com/..."
      },
      "content": "Check out the view from my run this morning! 🏃‍♂️",
      "message_type": "text",
      "media_url": null,
      "reply_to_message": null,
      "is_edited": false,
      "created_at": "2024-01-01T10:15:00Z",
      "read_by": [
        {
          "user_id": "uuid",
          "read_at": "2024-01-01T10:16:00Z"
        }
      ]
    },
    {
      "id": "system_message_uuid",
      "conversation_id": "conversation_uuid",
      "sender": null,
      "content": "Brian Onyango completed the 'Run 10k this week' goal!",
      "message_type": "system",
      "metadata": {
        "goal_id": "goal_uuid",
        "goal_title": "Run 10k this week"
      },
      "created_at": "2024-01-01T10:10:00Z"
    }
  ],
  "pagination": {
    "has_more": true,
    "next_cursor": "message_uuid"
  }
}
```

#### POST /api/v1/conversations/:conversationId/messages

**Request:**
```json
{
  "content": "Awesome! Great job!",
  "message_type": "text",
  "reply_to_message_id": null
}
```

**Response (201):**
```json
{
  "id": "message_uuid",
  "conversation_id": "conversation_uuid",
  "sender": {
    "id": "user_uuid",
    "username": "currentuser",
    "full_name": "Current User",
    "profile_image_url": "https://cdn.example.com/..."
  },
  "content": "Awesome! Great job!",
  "message_type": "text",
  "created_at": "2024-01-01T10:20:00Z"
}
```

### 4.8 AI Coach Endpoints

```
POST   /api/v1/ai-coach/chat
GET    /api/v1/ai-coach/conversations/:conversationId
GET    /api/v1/ai-coach/suggestions
```

#### POST /api/v1/ai-coach/chat

**Request:**
```json
{
  "message": "How can I stay motivated to reach my savings goal?",
  "conversation_id": "conversation_uuid",
  "context": {
    "current_goals": ["goal_uuid1", "goal_uuid2"]
  }
}
```

**Response (200):**
```json
{
  "message": {
    "id": "message_uuid",
    "content": "Great question! Here are some strategies to stay motivated for your savings goal...",
    "message_type": "text",
    "created_at": "2024-01-01T12:00:00Z"
  },
  "suggestions": [
    "Tell me more about your goal",
    "How can I track my progress?",
    "What are some saving tips?"
  ]
}
```

### 4.9 Notifications Endpoints

```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread-count
PUT    /api/v1/notifications/:notificationId/read
PUT    /api/v1/notifications/mark-all-read
DELETE /api/v1/notifications/:notificationId
GET    /api/v1/notifications/preferences
PUT    /api/v1/notifications/preferences
POST   /api/v1/notifications/push-tokens
DELETE /api/v1/notifications/push-tokens/:tokenId
```

#### GET /api/v1/notifications

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `filter` (options: 'all', 'goals', 'social', 'system')
- `unread_only` (boolean)

**Response (200):**
```json
{
  "notifications": [
    {
      "id": "notification_uuid",
      "notification_type": "goal_completed",
      "title": "Goal Completed! 🎉",
      "message": "You and 3 friends completed \"Run a 5k\" goal",
      "related_user": {
        "id": "user_uuid",
        "username": "alvinamwata",
        "profile_image_url": "https://cdn.example.com/..."
      },
      "related_goal": {
        "id": "goal_uuid",
        "title": "Run a 5k"
      },
      "image_url": "https://cdn.example.com/...",
      "icon_type": "celebration",
      "icon_color": "#FF6B6B",
      "action_url": "/goals/uuid",
      "is_read": false,
      "time_ago": "2 hours ago",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "unread_count": 4
  }
}
```

#### GET /api/v1/notifications/preferences

**Response (200):**
```json
{
  "push_enabled": true,
  "email_enabled": false,
  "goal_reminders": true,
  "friend_requests": true,
  "messages": true,
  "achievements": true,
  "post_likes": true,
  "post_comments": true,
  "goal_updates": true,
  "updated_at": "2024-01-01T12:00:00Z"
}
```

### 4.10 Settings Endpoints

```
GET    /api/v1/settings
PUT    /api/v1/settings
GET    /api/v1/settings/privacy
PUT    /api/v1/settings/privacy
GET    /api/v1/settings/appearance
PUT    /api/v1/settings/appearance
POST   /api/v1/settings/blocked-users
DELETE /api/v1/settings/blocked-users/:userId
GET    /api/v1/settings/blocked-users
POST   /api/v1/settings/download-data
DELETE /api/v1/settings/delete-account
```

#### GET /api/v1/settings

**Response (200):**
```json
{
  "user_id": "user_uuid",
  "privacy": {
    "profile_visibility": "friends_only",
    "online_status_visible": true,
    "appear_in_suggestions": true,
    "who_can_send_friend_requests": "friends_of_friends",
    "who_can_send_messages": "friends_only",
    "share_activity_with_friends": true
  },
  "appearance": {
    "theme_mode": "dark",
    "accent_color": "#FF6B6B",
    "font_size_multiplier": 1.0
  },
  "notifications": {
    "push_enabled": true,
    "email_enabled": false,
    "goal_reminders": true,
    "friend_requests": true,
    "messages": true,
    "achievements": true
  }
}
```

#### PUT /api/v1/settings/privacy

**Request:**
```json
{
  "profile_visibility": "friends_only",
  "online_status_visible": true,
  "appear_in_suggestions": true,
  "who_can_send_friend_requests": "friends_of_friends",
  "who_can_send_messages": "friends_only",
  "share_activity_with_friends": true
}
```

**Response (200):**
```json
{
  "profile_visibility": "friends_only",
  "online_status_visible": true,
  "appear_in_suggestions": true,
  "who_can_send_friend_requests": "friends_of_friends",
  "who_can_send_messages": "friends_only",
  "share_activity_with_friends": true,
  "updated_at": "2024-01-01T12:00:00Z"
}
```

### 4.11 Search Endpoints

```
GET    /api/v1/search?q=query&type=all
GET    /api/v1/search/users?q=query
GET    /api/v1/search/goals?q=query
GET    /api/v1/search/posts?q=query
```

#### GET /api/v1/search

**Query Parameters:**
- `q` (required) - Search query
- `type` (options: 'all', 'users', 'goals', 'posts')
- `page` (default: 1)
- `limit` (default: 20)

**Response (200):**
```json
{
  "users": [
    {
      "id": "user_uuid",
      "username": "derrickjuma",
      "full_name": "Derrick Juma",
      "profile_image_url": "https://cdn.example.com/...",
      "is_friend": false,
      "mutual_friends_count": 5
    }
  ],
  "goals": [
    {
      "id": "goal_uuid",
      "title": "Run a Marathon",
      "category": "fitness",
      "progress_percentage": 45,
      "participants_count": 8
    }
  ],
  "posts": [
    {
      "id": "post_uuid",
      "user": {
        "username": "alvinamwata",
        "full_name": "Alvin Amwata"
      },
      "caption": "Morning run completed!",
      "media_thumbnail_url": "https://cdn.example.com/..."
    }
  ]
}
```

---

## 5. Real-Time Features

### 5.1 WebSocket Connection

**Connection URL:**
```
wss://api.tribe.app/ws?token=jwt_token
```

**Connection Flow:**
1. Client establishes WebSocket connection with JWT token
2. Server authenticates and associates connection with user
3. Server sends connection confirmation
4. Client subscribes to channels
5. Server pushes real-time updates

### 5.2 WebSocket Events

#### Client → Server Events

```json
// Subscribe to conversation
{
  "event": "subscribe",
  "channel": "conversation",
  "conversation_id": "uuid"
}

// Send typing indicator
{
  "event": "typing",
  "conversation_id": "uuid",
  "is_typing": true
}

// Mark as online
{
  "event": "presence",
  "status": "online"
}
```

#### Server → Client Events

```json
// New message
{
  "event": "message.new",
  "conversation_id": "uuid",
  "message": {
    "id": "message_uuid",
    "sender": {
      "id": "user_uuid",
      "username": "brianonyango",
      "full_name": "Brian Onyango"
    },
    "content": "Hey! How are you?",
    "created_at": "2024-01-01T12:00:00Z"
  }
}

// Message read
{
  "event": "message.read",
  "conversation_id": "uuid",
  "message_id": "message_uuid",
  "user_id": "reader_uuid",
  "read_at": "2024-01-01T12:00:00Z"
}

// Typing indicator
{
  "event": "typing",
  "conversation_id": "uuid",
  "user": {
    "id": "user_uuid",
    "username": "derrickjuma",
    "full_name": "Derrick Juma"
  },
  "is_typing": true
}

// New notification
{
  "event": "notification.new",
  "notification": {
    "id": "notification_uuid",
    "title": "New Like",
    "message": "Alvin Amwata liked your memory",
    "notification_type": "post_like"
  }
}

// Goal update
{
  "event": "goal.update",
  "goal_id": "goal_uuid",
  "update_type": "contribution",
  "data": {
    "user": {
      "username": "clariegor",
      "full_name": "Clarie Gor"
    },
    "amount": 150.00,
    "new_progress": 70
  }
}

// User online status
{
  "event": "presence.update",
  "user_id": "user_uuid",
  "status": "online",
  "last_seen_at": "2024-01-01T12:00:00Z"
}
```

### 5.3 Redis Pub/Sub Channels

```python
# Channel patterns
user:{user_id}                    # User-specific events
conversation:{conversation_id}     # Conversation events
goal:{goal_id}                    # Goal updates
presence                          # Online status updates
notifications:{user_id}           # User notifications
```

---

## 6. AI Integration

### 6.1 AI Coach Implementation

**Technology:** OpenAI GPT-4 API

**System Prompt:**
```
You are Tribe Coach, an AI assistant for the Tribe app that helps users achieve their goals 
and maintain strong friendships. You are supportive, motivational, and practical. You help 
users with:
- Goal setting and tracking
- Accountability strategies
- Friendship maintenance tips
- Motivational support
- Progress analysis

Keep responses concise, friendly, and actionable. Reference the user's specific goals and 
friends when relevant.
```

**Context Management:**
```python
# Include in each AI request
context = {
    "user_profile": {
        "name": "Brian Okuku",
        "goals_achieved": 5,
        "active_goals": [...]
    },
    "recent_goals": [...],
    "friend_activities": [...],
    "conversation_history": [...]  # Last 10 messages
}
```

### 6.2 AI Features

1. **Goal Coaching**
   - Personalized suggestions based on user goals
   - Progress analysis and insights
   - Milestone recommendations

2. **Motivation & Support**
   - Encouragement messages
   - Celebration of achievements
   - Recovery from setbacks

3. **Social Insights**
   - Friend activity summaries
   - Connection recommendations
   - Group goal suggestions

4. **Smart Reminders**
   - Context-aware check-ins
   - Optimal timing for interactions
   - Personalized frequency

### 6.3 AI Response Caching

```python
# Cache common queries for 1 hour
cache_key = f"ai:response:{user_id}:{message_hash}"

# Use Redis for fast retrieval
if cached_response := redis.get(cache_key):
    return cached_response

response = openai_api.chat.completions.create(...)
redis.setex(cache_key, 3600, response)
```

---

## 7. File Storage Strategy

### 7.1 Storage Architecture

**Service:** AWS S3 / CloudFlare R2

**Bucket Structure:**
```
tribe-app-media/
├── users/
│   ├── {user_id}/
│   │   ├── profile/
│   │   │   ├── original.jpg
│   │   │   ├── large.jpg (800x800)
│   │   │   ├── medium.jpg (400x400)
│   │   │   └── thumb.jpg (150x150)
│   │   └── cover/
│   │       ├── original.jpg
│   │       └── large.jpg (1200x400)
├── posts/
│   ├── {post_id}/
│   │   ├── original.jpg
│   │   ├── large.jpg (1080x1350)
│   │   ├── medium.jpg (640x800)
│   │   └── thumb.jpg (320x400)
├── stories/
│   ├── {story_id}/
│   │   ├── original.jpg
│   │   └── thumb.jpg
└── goals/
    └── {goal_id}/
        ├── original.jpg
        └── thumb.jpg
```

### 7.2 Upload Flow

```python
from PIL import Image
import boto3

async def upload_post_image(user_id: UUID, file: UploadFile) -> dict:
    # 1. Validate file
    validate_image(file)  # Type, size, dimensions
    
    # 2. Generate unique ID
    post_id = uuid4()
    
    # 3. Process image
    original = Image.open(file.file)
    
    # 4. Generate variants
    variants = {
        'original': original,
        'large': resize_image(original, 1080, 1350),
        'medium': resize_image(original, 640, 800),
        'thumb': resize_image(original, 320, 400)
    }
    
    # 5. Upload to S3
    urls = {}
    for variant_name, image in variants.items():
        key = f"posts/{post_id}/{variant_name}.jpg"
        urls[variant_name] = await upload_to_s3(key, image)
    
    return {
        'post_id': post_id,
        'media_url': urls['large'],
        'media_thumbnail_url': urls['thumb']
    }
```

### 7.3 CDN Configuration

**CloudFront / CloudFlare CDN:**
- Cache images for 30 days
- Automatic image optimization
- Responsive image delivery
- Geographic distribution

---

## 8. Security & Authentication

### 8.1 JWT Authentication

**Access Token:**
```python
{
    "type": "access",
    "user_id": "uuid",
    "username": "brianokuku",
    "email": "brian.okuku@example.com",
    "exp": 1735689600,  # 1 hour
    "iat": 1735686000
}
```

**Refresh Token:**
```python
{
    "type": "refresh",
    "user_id": "uuid",
    "token_id": "uuid",  # Stored in database
    "exp": 1738281600,  # 30 days
    "iat": 1735686000
}
```

### 8.2 Security Measures

1. **Password Security**
   - bcrypt hashing (cost factor: 12)
   - Minimum 8 characters
   - Complexity requirements
   - Password history (prevent reuse)

2. **Rate Limiting**
   ```python
   # Login attempts: 5 per 15 minutes
   # API requests: 100 per minute
   # File uploads: 10 per hour
   # Password reset: 3 per hour
   ```

3. **Input Validation**
   - Pydantic models for all inputs
   - SQL injection prevention (SQLAlchemy parameterization)
   - XSS prevention (sanitize outputs)
   - File upload validation

4. **CORS Configuration**
   ```python
   ALLOWED_ORIGINS = [
       "https://tribe.app",
       "https://app.tribe.com",
       "tribe://app"  # Deep linking
   ]
   ```

5. **Data Encryption**
   - HTTPS/TLS 1.3 only
   - Encrypted fields: passwords, tokens
   - At-rest encryption for S3

### 8.3 API Security Middleware

```python
from fastapi import Security, HTTPException
from fastapi.security import HTTPBearer

security = HTTPBearer()

async def get_current_user(
    token: str = Security(security)
) -> User:
    try:
        payload = jwt.decode(
            token.credentials,
            SECRET_KEY,
            algorithms=["HS256"]
        )
        user_id = payload.get("user_id")
        user = await get_user_by_id(user_id)
        
        if not user or not user.is_active:
            raise HTTPException(401, "Invalid authentication")
        
        return user
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except jwt.JWTError:
        raise HTTPException(401, "Invalid token")
```

---

## 9. Performance Optimization

### 9.1 Database Optimization

**Indexing Strategy:**
```sql
-- Critical indexes for performance
CREATE INDEX CONCURRENTLY idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_notifications_user_read_created ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX CONCURRENTLY idx_friendships_user_status ON friendships(user_id, status);
CREATE INDEX CONCURRENTLY idx_goals_status_created ON goals(status, created_at DESC);

-- Composite indexes for common queries
CREATE INDEX CONCURRENTLY idx_feed_user_score ON feed_entries(user_id, score DESC, created_at DESC);
CREATE INDEX CONCURRENTLY idx_goal_participants_goal_joined ON goal_participants(goal_id, joined_at DESC);
```

**Query Optimization:**
```python
# Use select_related/joinedload for N+1 prevention
posts = await session.execute(
    select(Post)
    .options(
        joinedload(Post.user),
        joinedload(Post.goal),
        selectinload(Post.likes).joinedload(PostLike.user)
    )
    .where(Post.user_id.in_(friend_ids))
    .order_by(Post.created_at.desc())
    .limit(20)
)

# Use pagination with keyset pagination (faster than offset)
cursor = request.query_params.get('cursor')
query = select(Post).order_by(Post.created_at.desc())
if cursor:
    query = query.where(Post.created_at < cursor)
query = query.limit(20)
```

### 9.2 Caching Strategy

**Redis Cache Layers:**

```python
# Layer 1: Hot data (TTL: 5 minutes)
cache_keys = {
    f"user:{user_id}": user_data,
    f"user:{user_id}:friends": friend_list,
    f"user:{user_id}:online_friends": online_friends,
    f"goal:{goal_id}": goal_data,
    f"conversation:{conv_id}:unread": unread_count
}

# Layer 2: Warm data (TTL: 15 minutes)
cache_keys = {
    f"user:{user_id}:posts": user_posts,
    f"goal:{goal_id}:participants": participants,
    f"feed:{user_id}": feed_data
}

# Layer 3: Cold data (TTL: 1 hour)
cache_keys = {
    f"user:{user_id}:stats": user_stats,
    f"suggestions:{user_id}": friend_suggestions
}

# Cache invalidation patterns
async def invalidate_user_cache(user_id: UUID):
    patterns = [
        f"user:{user_id}",
        f"user:{user_id}:*",
        f"feed:{user_id}"
    ]
    for pattern in patterns:
        await redis.delete_pattern(pattern)
```

**Cache-Aside Pattern:**
```python
async def get_user_with_cache(user_id: UUID) -> User:
    cache_key = f"user:{user_id}"
    
    # Try cache first
    cached = await redis.get(cache_key)
    if cached:
        return User.parse_raw(cached)
    
    # Cache miss - fetch from DB
    user = await db.get(User, user_id)
    if user:
        await redis.setex(
            cache_key,
            300,  # 5 minutes
            user.json()
        )
    
    return user
```

### 9.3 Background Jobs (Celery)

```python
# Task definitions
@celery.task
async def process_image_upload(post_id: UUID):
    """Generate image thumbnails and variants"""
    pass

@celery.task
async def send_push_notification(user_id: UUID, notification_data: dict):
    """Send push notification via FCM"""
    pass

@celery.task
async def update_feed_entries(user_id: UUID):
    """Update user's feed with new content"""
    pass

@celery.task
async def cleanup_expired_stories():
    """Remove stories older than 24 hours"""
    pass

@celery.task
async def calculate_friend_suggestions(user_id: UUID):
    """Calculate and update friend suggestions"""
    pass

@celery.task
async def send_goal_reminders():
    """Send scheduled goal reminders"""
    pass

# Schedule configuration
celery.conf.beat_schedule = {
    'cleanup-stories': {
        'task': 'cleanup_expired_stories',
        'schedule': crontab(minute='*/15')  # Every 15 minutes
    },
    'update-friend-suggestions': {
        'task': 'calculate_friend_suggestions_batch',
        'schedule': crontab(hour=2, minute=0)  # Daily at 2 AM
    },
    'send-daily-reminders': {
        'task': 'send_goal_reminders',
        'schedule': crontab(hour='*/4')  # Every 4 hours
    }
}
```

### 9.4 Database Connection Pooling

```python
# SQLAlchemy async engine configuration
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,           # Connection pool size
    max_overflow=10,        # Extra connections if needed
    pool_pre_ping=True,     # Verify connections before use
    pool_recycle=3600,      # Recycle connections every hour
    echo=False,             # Disable SQL logging in production
    future=True
)

async_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)
```

---

## 10. Deployment Architecture

### 10.1 Infrastructure Overview

```
┌─────────────────┐
│   CloudFlare    │  (CDN + DDoS Protection)
│      CDN        │
└────────┬────────┘
         │
┌────────▼────────┐
│   Load Balancer │  (AWS ALB / nginx)
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ FastAPI│ │FastAPI│  (Auto-scaling group)
│ Server1│ │Server2│
└───┬────┘ └──┬────┘
    │         │
    └────┬────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ Redis │ │Postgres│
│Cluster│ │  RDS   │
└───────┘ └────────┘
    │
┌───▼────┐
│ Celery │
│Workers │
└────────┘
```

### 10.2 Container Configuration

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  api:
    build: .
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
    environment:
      - DATABASE_URL=postgresql+asyncpg://user:pass@postgres:5432/tribe
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    depends_on:
      - postgres
      - redis
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=tribe
      - POSTGRES_USER=tribe_user
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped

  celery_worker:
    build: .
    command: celery -A app.celery_app worker --loglevel=info
    environment:
      - DATABASE_URL=postgresql+asyncpg://user:pass@postgres:5432/tribe
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  celery_beat:
    build: .
    command: celery -A app.celery_app beat --loglevel=info
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### 10.3 Environment Configuration

**.env.production:**
```bash
# Application
APP_NAME=Tribe
APP_ENV=production
DEBUG=false
API_VERSION=v1

# Database
DATABASE_URL=postgresql+asyncpg://user:pass@rds-endpoint:5432/tribe
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=10

# Redis
REDIS_URL=redis://elasticache-endpoint:6379
REDIS_PASSWORD=secure_password

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30

# AWS
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
S3_BUCKET=tribe-app-media
CLOUDFRONT_DOMAIN=cdn.tribe.app

# OpenAI
OPENAI_API_KEY=your-openai-key
OPENAI_MODEL=gpt-4-turbo-preview

# Firebase (Push Notifications)
FIREBASE_CREDENTIALS_PATH=/secrets/firebase-credentials.json

# Sentry (Error Tracking)
SENTRY_DSN=your-sentry-dsn

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_PER_MINUTE=100

# CORS
ALLOWED_ORIGINS=https://tribe.app,https://app.tribe.com
```

### 10.4 Monitoring & Logging

**Logging Configuration:**
```python
import logging
from pythonjsonlogger import jsonlogger

logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    '%(asctime)s %(name)s %(levelname)s %(message)s'
)
logHandler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
```

**Metrics to Track:**
- API response times (p50, p95, p99)
- Error rates by endpoint
- Database query times
- Cache hit rates
- WebSocket connections
- Active users
- Message throughput
- Image processing time
- AI response time

**Tools:**
- **Sentry** - Error tracking
- **DataDog / New Relic** - APM
- **CloudWatch** - AWS metrics
- **Prometheus + Grafana** - Custom metrics

---

## 11. API Rate Limiting

```python
from fastapi import Request
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

# Rate limit configurations
RATE_LIMITS = {
    "auth": "5/minute",           # Login/register
    "api_read": "100/minute",     # GET requests
    "api_write": "30/minute",     # POST/PUT/DELETE
    "upload": "10/hour",          # File uploads
    "ai_coach": "20/hour"         # AI requests
}

@app.post("/api/v1/auth/login")
@limiter.limit("5/minute")
async def login(request: Request, credentials: LoginSchema):
    # Login logic
    pass
```

---

## 12. Testing Strategy

### 12.1 Unit Tests
```python
# tests/test_auth.py
import pytest
from app.services.auth import AuthService

@pytest.mark.asyncio
async def test_register_user():
    auth_service = AuthService()
    user = await auth_service.register(
        email="test@example.com",
        username="testuser",
        password="SecurePass123!"
    )
    assert user.email == "test@example.com"
    assert user.password_hash != "SecurePass123!"
```

### 12.2 Integration Tests
```python
# tests/test_api_goals.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_goal(client: AsyncClient, auth_headers):
    response = await client.post(
        "/api/v1/goals",
        headers=auth_headers,
        json={
            "title": "Test Goal",
            "target_amount": 1000.00,
            "goal_type": "individual"
        }
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Test Goal"
```

---

## 13. Migration Strategy

### 13.1 Database Migrations (Alembic)

```bash
# Create migration
alembic revision --autogenerate -m "Add user_achievements table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

### 13.2 Zero-Downtime Deployment

1. **Blue-Green Deployment**
   - Deploy new version to "green" environment
   - Run health checks
   - Switch traffic from "blue" to "green"
   - Keep "blue" as rollback

2. **Database Migrations**
   - Always backward compatible
   - Add columns as nullable first
   - Remove columns in subsequent release

---

## Conclusion

This comprehensive backend implementation plan provides a complete, production-ready architecture for the Tribe app. The system is designed to be:

- **Scalable**: Horizontal scaling of API servers, database replication
- **Efficient**: Caching strategies, optimized queries, background jobs
- **Fast**: Sub-100ms API responses, real-time WebSocket updates
- **Secure**: JWT authentication, rate limiting, input validation
- **Maintainable**: Clean architecture, comprehensive testing, monitoring

### Next Steps

1. **Phase 1 (Weeks 1-2)**: Core infrastructure, authentication, user profiles
2. **Phase 2 (Weeks 3-4)**: Goals, social features, friendships
3. **Phase 3 (Weeks 5-6)**: Messaging, real-time chat, WebSocket
4. **Phase 4 (Weeks 7-8)**: Posts, stories, feed algorithm
5. **Phase 5 (Weeks 9-10)**: AI integration, notifications, push
6. **Phase 6 (Weeks 11-12)**: Testing, optimization, deployment

### Estimated Costs (Monthly)

- **AWS EC2** (t3.medium x2): $60
- **RDS PostgreSQL** (db.t3.medium): $50
- **ElastiCache Redis** (cache.t3.small): $25
- **S3 + CloudFront**: $30
- **OpenAI API**: $100-200 (depends on usage)
- **Total**: ~$265-365/month (scales with usage)

This plan ensures every feature in your Flutter app has a corresponding, well-architected backend implementation.

