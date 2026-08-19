 # Marketplace Hub

A full-stack, OLX-style classifieds marketplace where users can browse categories, post ads with images and location, chat with sellers in real time, and manage favorites — built with a **Spring Boot** REST API backend and a **Flutter** cross-platform frontend.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [API Reference](#api-reference)
- [Environment Variables](#environment-variables)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview

Marketplace Hub is split into two independent projects that talk to each other over HTTP:

| Component | Path | Description |
|---|---|---|
| **Backend** | [`backend/`](backend) | Java 21 / Spring Boot 3 REST API with JWT + Google Sign-In auth, PostgreSQL persistence, and image uploads |
| **Frontend** | [`olx_marketplace/`](olx_marketplace) | Flutter app (Android, iOS, web, Windows, macOS, Linux) that consumes the API |

## Architecture

Marketplace Hub follows a classic **3-tier client–server architecture**:

```
                        ┌───────────────────────┐
                        │   Google OAuth2        │
                        │   (ID token verify)    │
                        └──────────┬─────────────┘
                                   │
┌───────────────────┐             │
│   Flutter client    │             │
│  Android · iOS ·    │             │
│  Web · Desktop       │             │
└─────────┬───────────┘             │
          │ HTTPS / REST (JSON)     │
          ▼                         ▼
┌─────────────────────────────────────────────────┐
│              Spring Boot REST API                 │
│              (JWT-secured, port 8080)              │
│  ┌─────────────┐  ┌───────────┐  ┌──────────────┐ │
│  │ Controllers  │─▶│  Services  │─▶│ Repositories  │ │
│  │ HTTP layer   │  │ Business   │  │ Spring Data   │ │
│  │              │  │ logic      │  │ JPA           │ │
│  └─────────────┘  └───────────┘  └──────┬───────┘ │
└──────────────────────────────────────────┼─────────┘
                                            ▼
                                 ┌─────────────────────┐
                                 │  PostgreSQL database  │
                                 │  ads · users · chats · │
                                 │  favorites · categories │
                                 └─────────────────────┘
```

**Request flow:**

1. The **Flutter client** (mobile/web/desktop) sends HTTPS requests to the API, resolving the base URL per-platform in `lib/services/api_client.dart` (`10.0.2.2` for the Android emulator, `localhost` elsewhere).
2. **`JwtAuthenticationFilter`** (in `security/`) intercepts each request, validates the bearer token issued at login, and populates the Spring Security context. Login itself is handled two ways: email/password via `AuthService`, or Google Sign-In, where the client sends a Google ID token that the backend verifies against `GOOGLE_CLIENT_ID` using the Google API client.
3. **Controllers** (`controller/`) map HTTP routes to actions and delegate to services — no business logic lives here.
4. **Services** (`service/`) contain the actual business rules (creating ads, managing chat rooms, toggling favorites, etc.) and orchestrate one or more repositories.
5. **Repositories** (`repository/`), built on Spring Data JPA, persist and query **entities** (`entity/`) — `User`, `Ad`, `Category`, `ChatRoom`, `ChatMessage`, `Favorite`, and related enums — against PostgreSQL. Schema is kept in sync automatically via `spring.jpa.hibernate.ddl-auto=update`, and `DataSeeder` (in `config/`) seeds baseline reference data (e.g. categories) on startup.
6. **DTOs** (`dto/`, grouped by feature — `ad`, `auth`, `category`, `chat`, `user`, `home`, `common`) shape request/response payloads so entities are never exposed directly over the API.
7. Uploaded ad images are handled by `FileStorageService` / `FileUploadController` and written to the directory configured by `FILE_UPLOAD_DIR`.
8. Cross-origin access for the Flutter web build is enabled via `CorsConfig`.

## Tech Stack

**Backend**
- Java 21, Spring Boot 3.3.4
- Spring Web, Spring Data JPA, Spring Security
- PostgreSQL
- JWT authentication (`jjwt`) + Google OAuth2 ID token verification
- Lombok, Bean Validation
- Maven

**Frontend**
- Flutter (Dart SDK `^3.12.2`)
- `google_fonts`, `cached_network_image` for UI/UX
- `google_sign_in` for social login
- `http` + `shared_preferences` for networking and local storage
- `flutter_map`, `latlong2`, `geolocator` for OpenStreetMap-based location features

## Project Structure

```
Marketplace-Hub/
├── backend/                          # Spring Boot REST API
│   ├── src/main/java/com/olx/marketplace/
│   │   ├── config/                   # Security, CORS, MVC config, dev data seeder
│   │   ├── controller/                # REST controllers (Ads, Auth, Chat, Users, ...)
│   │   ├── dto/                      # Request/response DTOs, grouped by feature
│   │   ├── entity/                   # JPA entities (Ad, User, ChatRoom, Category, ...)
│   │   ├── exception/                 # Centralized exception handling
│   │   ├── repository/                # Spring Data JPA repositories
│   │   ├── security/                 # JWT filter/service, UserDetailsService
│   │   └── service/                  # Business logic layer
│   ├── src/main/resources/
│   │   └── application.properties     # Externalized, env-driven configuration
│   ├── .env.example                  # Sample environment variables
│   └── pom.xml
│
└── olx_marketplace/                  # Flutter client
    ├── lib/
    │   ├── core/                     # Constants and app theme
    │   ├── data/                     # Mock data (used before/without a live backend)
    │   ├── models/                   # Dart data models (Ad, User, Chat, ...)
    │   ├── screens/                  # App screens (home, auth, chat, listings, ...)
    │   ├── services/                 # API client + feature services (auth, ads, chat, ...)
    │   ├── widgets/                  # Reusable UI components
    │   └── main.dart
    ├── android/ ios/ web/ windows/ macos/ linux/   # Platform-specific projects
    └── pubspec.yaml
```

## Features

- **Authentication** — email/password registration & login plus Google Sign-In, backed by JWTs
- **Ad listings** — create, browse, search, edit, mark-as-sold, and delete classified ads with images
- **Categories & subcategories** — browse ads by category
- **Chat** — per-ad chat rooms and messaging between buyers and sellers
- **Favorites** — save and manage favorite ads
- **Location** — map-based location picking and viewing via OpenStreetMap
- **Image uploads** — single and multi-image upload support for ad listings
- **User profile management** — view, update, and delete your account

## Getting Started

### Prerequisites

- **Java 21+** and **Maven** (a local Maven wrapper/distribution is also vendored under `backend/maven`)
- **PostgreSQL** (running locally or accessible remotely)
- **Flutter SDK** (compatible with Dart `^3.12.2`) — see the [Flutter install guide](https://docs.flutter.dev/get-started/install)
- A **Google OAuth2 Client ID** if you want Google Sign-In to work end-to-end

### Backend Setup

1. **Create a PostgreSQL database**

   ```sql
   CREATE DATABASE olx_marketplace;
   ```

2. **Configure environment variables**

   Copy the example env file and fill in your own values:

   ```bash
   cd backend
   cp .env.example .env
   ```

   ```env
   SERVER_PORT=8080

   SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/olx_marketplace
   SPRING_DATASOURCE_USERNAME=your_db_username
   SPRING_DATASOURCE_PASSWORD=your_db_password

   JWT_SECRET=your_jwt_secret_key_base64_encoded
   JWT_EXPIRATION=86400000

   FILE_UPLOAD_DIR=uploads
   ```

   > `application.properties` also reads `GOOGLE_CLIENT_ID` for Google Sign-In verification — set it if you're using that flow.

3. **Run the API**

   ```bash
   # from backend/
   ./mvnw spring-boot:run        # if a Maven wrapper is present
   # or, using the vendored Maven distribution:
   ./maven/apache-maven-3.9.6/bin/mvn spring-boot:run
   ```

   The API starts on `http://localhost:8080` by default. JPA is configured with `ddl-auto=update`, so tables are created/updated automatically on startup, and a `DataSeeder` populates initial reference data (e.g. categories) in dev.

4. **Verify it's running**

   ```bash
   curl http://localhost:8080/api/health
   ```

### Frontend Setup

1. **Install dependencies**

   ```bash
   cd olx_marketplace
   flutter pub get
   ```

2. **Point the app at your backend**

   The API base URL is resolved automatically in `lib/services/api_client.dart`:
   - `http://10.0.2.2:8080/api` when running on the Android emulator
   - `http://localhost:8080/api` everywhere else

   Update this if your backend runs on a different host/port or a physical device.

3. **Run the app**

   ```bash
   flutter run
   ```

   Or target a specific platform, e.g. `flutter run -d chrome` / `flutter run -d windows`.

## API Reference

All endpoints are prefixed with `/api`. Endpoints marked 🔒 require a valid JWT (`Authorization: Bearer <token>`).

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/health` | Health check |
| POST | `/api/auth/register` | Register with email & password |
| POST | `/api/auth/login` | Log in with email & password |
| POST | `/api/auth/google` | Log in / sign up with a Google ID token |
| GET | `/api/home` | Aggregated home-screen data |
| GET | `/api/categories` | List categories |
| GET | `/api/categories/{id}` | Get a category |
| GET | `/api/categories/{id}/subcategories` | List subcategories |
| POST | `/api/categories` | 🔒 Create a category |
| POST | `/api/ads` | 🔒 Create an ad |
| GET | `/api/ads` | List ads |
| GET | `/api/ads/search` | Search ads |
| GET | `/api/ads/{id}` | Get ad details |
| GET | `/api/ads/my` | 🔒 List the current user's ads |
| PUT | `/api/ads/{id}` | 🔒 Update an ad |
| PATCH | `/api/ads/{id}/sold` | 🔒 Mark an ad as sold |
| DELETE | `/api/ads/{id}` | 🔒 Delete an ad |
| GET | `/api/users/me` | 🔒 Get current user profile |
| PUT | `/api/users/me` | 🔒 Update current user profile |
| DELETE | `/api/users/me` | 🔒 Delete current user account |
| POST | `/api/favorites/{adId}` | 🔒 Add ad to favorites |
| DELETE | `/api/favorites/{adId}` | 🔒 Remove ad from favorites |
| GET | `/api/favorites` | 🔒 List favorite ads |
| POST | `/api/chats/room` | 🔒 Create/get a chat room for an ad |
| GET | `/api/chats/rooms` | 🔒 List chat rooms |
| GET | `/api/chats/rooms/{roomId}/messages` | 🔒 List messages in a room |
| POST | `/api/chats/rooms/{roomId}/messages` | 🔒 Send a message |
| POST | `/api/upload/image` | 🔒 Upload a single image |
| POST | `/api/upload/images` | 🔒 Upload multiple images |

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `SERVER_PORT` | `8080` | Port the backend listens on |
| `SPRING_DATASOURCE_URL` | `jdbc:postgresql://localhost:5432/olx_marketplace` | PostgreSQL connection URL |
| `SPRING_DATASOURCE_USERNAME` | `postgres` | Database username |
| `SPRING_DATASOURCE_PASSWORD` | `postgres` | Database password |
| `JWT_SECRET` | — | Base64-encoded secret used to sign JWTs |
| `JWT_EXPIRATION` | `86400000` (24h) | JWT expiry in milliseconds |
| `FILE_UPLOAD_DIR` | `uploads` | Directory where uploaded images are stored |
| `GOOGLE_CLIENT_ID` | — | Google OAuth2 client ID for verifying Google Sign-In tokens |

> ⚠️ The default values shown in `application.properties` are for local development only — always set real secrets via environment variables (or `.env`) rather than committing them.

## Roadmap

Ideas for future improvement:
- Push notifications for new chat messages
- Ad promotion / boosted listings
- Reviews and seller ratings
- Automated tests and CI pipeline

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to your branch and open a Pull Request

## License

No license has been specified for this project yet. Add a `LICENSE` file to clarify how others may use this code.
