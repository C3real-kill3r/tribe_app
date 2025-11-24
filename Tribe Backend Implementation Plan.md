# Tribe Backend Implementation Plan

This document outlines the detailed backend implementation plan for the Tribe app, designed to support all current features including authentication, goals, memories, chat, profile management, and AI coaching. The backend will be built using **Python FastAPI** and **PostgreSQL**, focusing on scalability, efficiency, and speed.

## 1. Architecture Overview

-   **Framework**: FastAPI (Python 3.10+) - Chosen for high performance (async support), automatic documentation (OpenAPI), and developer speed.
-   **Database**: PostgreSQL (v15+) - Robust relational database for structured data (users, goals, chats).
-   **ORM**: SQLAlchemy (Async) or Tortoise ORM - For efficient database interactions.
-   **Migrations**: Alembic - For database schema version control.
-   **Authentication**: JWT (JSON Web Tokens) - Stateless authentication. OAuth2 for social login (Google/Apple).
-   **Real-time**: WebSockets - For instant chat messages and notifications.
-   **AI Integration**: LangChain / OpenAI API (or similar) - For the AI Coach feature.
-   **Storage**: AWS S3 (or compatible object storage) - For user avatars, cover photos, and memory images.
-   **Caching**: Redis - For caching frequent queries, session management, and task queues (Celery/Arq).

---

## 2. Database Schema Design

### 2.1 Users & Authentication

**Table: `users`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK, Default: uuid_generate_v4() | Unique user identifier |
| `email` | VARCHAR(255) | Unique, Not Null | User email address |
| `hashed_password` | VARCHAR | Nullable | For email/password auth |
| `full_name` | VARCHAR(100) | Not Null | Display name |
| `username` | VARCHAR(50) | Unique, Not Null | Unique handle (@username) |
| `photo_url` | VARCHAR | Nullable | Profile picture URL |
| `cover_photo_url` | VARCHAR | Nullable | Profile cover image URL |
| `bio` | TEXT | Nullable | User biography |
| `created_at` | TIMESTAMP | Default: NOW() | Account creation time |
| `updated_at` | TIMESTAMP | Default: NOW() | Last update time |
| `is_active` | BOOLEAN | Default: True | Soft delete / ban status |

**Table: `friendships`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | UUID | FK -> users.id, PK | Requester |
| `friend_id` | UUID | FK -> users.id, PK | Accepter |
| `status` | ENUM | 'pending', 'accepted', 'blocked' | Friendship status |
| `created_at` | TIMESTAMP | Default: NOW() | |

### 2.2 Goals (Accountability)

**Table: `goals`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | Unique goal ID |
| `creator_id` | UUID | FK -> users.id | User who created the goal |
| `title` | VARCHAR(255) | Not Null | Goal name (e.g., "Run a 5k") |
| `description` | TEXT | Nullable | Detailed description |
| `target_type` | ENUM | 'amount', 'date', 'boolean' | Type of target |
| `target_value` | DECIMAL | Nullable | Numeric target (e.g., $2000) |
| `target_date` | DATE | Nullable | Deadline |
| `status` | ENUM | 'active', 'completed', 'archived' | Goal status |
| `progress` | DECIMAL | Default: 0.0 | Current progress (0.0 to 1.0 or value) |
| `created_at` | TIMESTAMP | Default: NOW() | |

**Table: `goal_participants`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `goal_id` | UUID | FK -> goals.id, PK | |
| `user_id` | UUID | FK -> users.id, PK | |
| `role` | ENUM | 'owner', 'member', 'viewer' | Permission level |
| `joined_at` | TIMESTAMP | Default: NOW() | |

### 2.3 Memories (Social Feed)

**Table: `posts`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | Unique post ID |
| `user_id` | UUID | FK -> users.id | Author |
| `goal_id` | UUID | FK -> goals.id, Nullable | Linked goal (optional) |
| `image_url` | VARCHAR | Not Null | Main content image |
| `caption` | TEXT | Nullable | Post text |
| `location` | VARCHAR | Nullable | Location tag |
| `created_at` | TIMESTAMP | Default: NOW() | |

**Table: `comments`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | |
| `post_id` | UUID | FK -> posts.id | |
| `user_id` | UUID | FK -> users.id | Author |
| `content` | TEXT | Not Null | Comment text |
| `created_at` | TIMESTAMP | Default: NOW() | |

**Table: `likes`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `post_id` | UUID | FK -> posts.id, PK | |
| `user_id` | UUID | FK -> users.id, PK | |
| `created_at` | TIMESTAMP | Default: NOW() | |

### 2.4 Chat & Messaging

**Table: `conversations`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | |
| `type` | ENUM | 'direct', 'group' | Chat type |
| `name` | VARCHAR | Nullable | Group name (null for DM) |
| `image_url` | VARCHAR | Nullable | Group icon |
| `last_message_at` | TIMESTAMP | | For sorting |
| `created_at` | TIMESTAMP | Default: NOW() | |

**Table: `conversation_participants`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `conversation_id` | UUID | FK -> conversations.id, PK | |
| `user_id` | UUID | FK -> users.id, PK | |
| `joined_at` | TIMESTAMP | Default: NOW() | |

**Table: `messages`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | |
| `conversation_id` | UUID | FK -> conversations.id | |
| `sender_id` | UUID | FK -> users.id | |
| `content` | TEXT | Nullable | Text content |
| `image_url` | VARCHAR | Nullable | Image attachment |
| `is_system` | BOOLEAN | Default: False | System messages (e.g., "User joined") |
| `created_at` | TIMESTAMP | Default: NOW() | |

**Table: `message_reads`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `message_id` | UUID | FK -> messages.id, PK | |
| `user_id` | UUID | FK -> users.id, PK | |
| `read_at` | TIMESTAMP | Default: NOW() | |

### 2.5 AI Coaching

**Table: `ai_chat_sessions`**
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | |
| `user_id` | UUID | FK -> users.id | |
| `context_summary` | JSONB | Nullable | Summarized context for LLM memory |
| `created_at` | TIMESTAMP | Default: NOW() | |
| `updated_at` | TIMESTAMP | Default: NOW() | |

---

## 3. API Endpoints

### 3.1 Authentication (`/auth`)
-   `POST /auth/register`: Create new account.
-   `POST /auth/login`: Login with email/password (returns JWT).
-   `POST /auth/google`: Login/Register with Google token.
-   `POST /auth/refresh`: Refresh access token.
-   `POST /auth/logout`: Invalidate token (if using blacklist).

### 3.2 Users & Profile (`/users`)
-   `GET /users/me`: Get current user profile.
-   `PATCH /users/me`: Update profile (name, bio, photo, cover).
-   `GET /users/{user_id}`: Get public profile of another user.
-   `GET /users/search?q={query}`: Search users by name/username.
-   `POST /users/friends/request`: Send friend request.
-   `PUT /users/friends/{request_id}/accept`: Accept friend request.
-   `GET /users/me/friends`: List friends.
-   `GET /users/me/stats`: Get user stats (goals achieved, photos shared).

### 3.3 Goals (`/goals`)
-   `POST /goals`: Create a new goal.
-   `GET /goals`: List user's active goals.
-   `GET /goals/{goal_id}`: Get goal details.
-   `PATCH /goals/{goal_id}`: Update goal (progress, details).
-   `POST /goals/{goal_id}/invite`: Invite friends to goal.
-   `POST /goals/{goal_id}/join`: Join a goal.

### 3.4 Memories / Feed (`/posts`)
-   `POST /posts`: Create a new memory (upload image + caption).
-   `GET /posts`: Get feed (friends' posts + own posts).
-   `GET /posts/{post_id}`: Get single post details.
-   `POST /posts/{post_id}/like`: Like a post.
-   `DELETE /posts/{post_id}/like`: Unlike a post.
-   `POST /posts/{post_id}/comments`: Add a comment.
-   `GET /posts/{post_id}/comments`: Get comments for a post.

### 3.5 Chat (`/chat`)
-   `GET /chat/conversations`: List all conversations (DM & Group).
-   `POST /chat/conversations`: Start a new DM or Group chat.
-   `GET /chat/conversations/{conversation_id}/messages`: Get message history (paginated).
-   `WS /ws/chat`: WebSocket endpoint for real-time messaging.

### 3.6 AI Coach (`/ai`)
-   `POST /ai/chat`: Send message to AI coach (streaming response).
-   `GET /ai/history`: Get AI chat history.
-   **Integration Logic**:
    -   Receive user message.
    -   Retrieve user context (active goals, recent mood/activity) from DB.
    -   Construct prompt for LLM (e.g., "You are a supportive accountability coach...").
    -   Call LLM API (OpenAI/Anthropic).
    -   Stream response back to client.
    -   Save interaction to `ai_chat_sessions`.

---

## 4. Scalability, Efficiency & Speed

### 4.1 Performance Optimization
-   **Async I/O**: Leveraging FastAPI's async capabilities for non-blocking database and API calls.
-   **Database Indexing**:
    -   Index `user_id` on all foreign keys.
    -   Index `created_at` for feed sorting.
    -   Index `email` and `username` for fast lookups.
-   **Connection Pooling**: Use `pgbouncer` or SQLAlchemy's internal pooling to manage DB connections efficiently.

### 4.2 Caching Strategy (Redis)
-   **User Sessions**: Cache user profile data to reduce DB hits on every request.
-   **Feed**: Cache the "For You" or "Friends" feed for a short duration (e.g., 1-5 mins).
-   **Counts**: Cache like counts and comment counts, update periodically or on write-through.

### 4.3 Scalability
-   **Stateless Backend**: The FastAPI app will be stateless, allowing horizontal scaling (adding more worker nodes/containers) behind a load balancer (Nginx/AWS ALB).
-   **Media Storage**: Offload all image processing and storage to a CDN-backed object storage (S3 + CloudFront). Do not serve files from the API server.
-   **Background Tasks**: Use Celery or Arq for heavy tasks (e.g., image resizing, sending push notifications, AI context summarization) to keep the API response time low.

### 4.4 Security
-   **HTTPS**: Enforce SSL/TLS.
-   **Input Validation**: Use Pydantic models for strict request validation.
-   **Rate Limiting**: Implement rate limiting (e.g., `slowapi`) to prevent abuse.
-   **Data Protection**: Hash passwords using bcrypt/Argon2.

## 5. Development Roadmap

1.  **Setup**: Initialize FastAPI project, Docker setup, DB configuration.
2.  **Auth Module**: Implement User model, registration, login, JWT handling.
3.  **Core Features**: Implement Goals and Profile CRUD.
4.  **Social Features**: Implement Friendships, Posts (Memories), Likes, Comments.
5.  **Chat Module**: Implement WebSocket logic and Chat persistence.
6.  **AI Integration**: Connect to LLM provider and build context-aware prompting.
7.  **Testing & Optimization**: Load testing, query optimization, caching implementation.
