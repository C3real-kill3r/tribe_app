# Authentication Implementation

This document describes the fully functional authentication system that has been implemented to integrate with the Tribe backend API.

## Overview

The authentication system includes:
- **Login** - Email and password authentication
- **Registration** - User signup with username, full name, email, and password
- **Token Management** - Secure storage of access and refresh tokens
- **Automatic Token Refresh** - Automatic refresh of expired access tokens
- **Session Management** - Persistent login sessions
- **Logout** - Secure token revocation

## Architecture

The implementation follows Clean Architecture principles:

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart          # API base URL configuration
│   ├── network/
│   │   └── api_client.dart          # HTTP client with interceptors
│   └── storage/
│       └── token_storage_service.dart  # Secure token storage
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_data_source.dart  # API calls
        │   ├── models/
        │   │   └── user_model.dart  # User data model
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── user.dart  # User entity
        │   └── repositories/
        │       └── auth_repository.dart  # Repository interface
        └── presentation/
            ├── bloc/
            │   ├── auth_bloc.dart  # State management
            │   ├── auth_event.dart
            │   └── auth_state.dart
            └── pages/
                ├── login_page.dart
                └── signup_page.dart
```

## Configuration

### Environment Variables (.env file)

The app uses a `.env` file for configuration. A `.env.example` file is provided as a template.

**Setup:**
1. Copy `.env.example` to `.env` (already done if you see `.env` file)
2. Update the values in `.env` based on your environment

**Available Variables:**
- `API_BASE_URL` - Backend API base URL (default: `http://localhost:8000`)
- `API_VERSION` - API version (default: `v1`)
- `ENV` - Environment (development/staging/production)
- `DEBUG` - Debug mode (true/false)

**Important:** Update `API_BASE_URL` in `.env` based on your environment:

- **Local development (Docker)**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:8000`)

**Note:** The `.env` file is gitignored for security. The `.env.example` file serves as a template and is committed to version control.

### Backend Requirements

Ensure your backend is running and accessible. The backend should be running on Docker as mentioned, typically at:
- URL: `http://localhost:8000` (or your configured port)
- API endpoints: `/api/v1/auth/*`

## Features

### 1. Login

- **Endpoint**: `POST /api/v1/auth/login`
- **Request**: Email and password
- **Response**: User data, access token, and refresh token
- **Features**:
  - Device information tracking
  - Automatic token storage
  - Error handling with user-friendly messages

### 2. Registration

- **Endpoint**: `POST /api/v1/auth/register`
- **Request**: Full name, username, email, password, confirm password
- **Response**: User data, access token, and refresh token
- **Validation**:
  - Username: 3-50 characters, alphanumeric and underscores only
  - Password: Minimum 8 characters, must contain uppercase, lowercase, and digit
  - Password confirmation must match

### 3. Token Management

- **Storage**: Tokens are stored securely using `flutter_secure_storage`
- **Access Token**: Used for API authentication
- **Refresh Token**: Used to obtain new access tokens when expired
- **Automatic Refresh**: Access tokens are automatically refreshed when they expire (401 responses)

### 4. Session Management

- **Persistent Sessions**: User sessions persist across app restarts
- **Auto-login**: Users are automatically logged in if valid tokens exist
- **Session Check**: Splash screen checks authentication status on app launch

### 5. Logout

- **Endpoint**: `POST /api/v1/auth/logout`
- **Features**:
  - Revokes refresh token on backend
  - Clears all local tokens and user data
  - Redirects to welcome/login screen

## Usage

### Login Flow

1. User enters email and password
2. App calls `/api/v1/auth/login` with credentials
3. Backend validates and returns tokens
4. Tokens are stored securely
5. User is redirected to home screen

### Registration Flow

1. User enters full name, username, email, password, and confirm password
2. Client-side validation checks format requirements
3. App calls `/api/v1/auth/register` with user data
4. Backend creates user and returns tokens
5. Tokens are stored securely
6. User is redirected to home screen

### Automatic Token Refresh

When an API call receives a 401 (Unauthorized) response:
1. The interceptor catches the error
2. Attempts to refresh the access token using the refresh token
3. Retries the original request with the new token
4. If refresh fails, clears tokens and redirects to login

## Error Handling

The implementation includes comprehensive error handling:

- **Network Errors**: User-friendly messages for connection issues
- **Validation Errors**: Clear messages for invalid input
- **Authentication Errors**: Proper handling of expired/invalid tokens
- **Backend Errors**: Parsing of backend error responses

## Security Features

1. **Secure Token Storage**: Uses Flutter Secure Storage (encrypted)
2. **HTTPS Ready**: Configure for HTTPS in production
3. **Token Refresh**: Automatic token rotation
4. **Token Revocation**: Proper logout with backend token invalidation

## Testing

To test the authentication:

1. **Start Backend**: Ensure Docker backend is running
2. **Update API URL**: Configure correct base URL for your environment
3. **Run App**: `fvm flutter run`
4. **Test Registration**: Create a new account
5. **Test Login**: Log in with existing credentials
6. **Test Persistence**: Close and reopen app (should stay logged in)
7. **Test Logout**: Log out and verify tokens are cleared

## Dependencies Added

- `dio: ^5.4.0` - HTTP client with interceptors
- `flutter_secure_storage: ^9.0.0` - Secure token storage
- `device_info_plus: ^9.1.0` - Device information for login tracking
- `package_info_plus: ^5.0.1` - App version information

## Next Steps

1. **Update API Base URL**: Configure for your environment
2. **Test Authentication**: Verify login/registration works
3. **Add Protected Routes**: Implement route guards for authenticated routes
4. **Add Error Recovery**: Implement retry logic for network failures
5. **Add Loading States**: Enhance UI with better loading indicators

## Notes

- The API client automatically adds the `Authorization: Bearer <token>` header to all requests
- Token refresh happens automatically and transparently
- User data is fetched from `/api/v1/auth/me` endpoint when checking current user
- All tokens are cleared on logout or authentication failure

