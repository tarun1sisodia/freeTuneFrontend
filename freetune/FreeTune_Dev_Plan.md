# 🎵 FreeTune: A Step-by-Step Development Plan

This document outlines the refined architectural plan and development workflow for the FreeTune Flutter application. It incorporates the core principles from `MEMO.md` and the GetX implementation strategy from `ap.md`, while structuring the development process in a logical, step-by-step manner.

---

## 🎯 Core Philosophy: Build Layers from the Ground Up

You've correctly identified that the app should be built in a specific order. The key principle is to **build a stable foundation before adding the complexities of features and UI**. This approach, known as Clean Architecture, ensures the app is scalable, maintainable, and easy to test.

Here is the logical flow we will follow:

1.  **Foundation First:** Configure the core aspects of the app.
2.  **Data Layer:** Define what our data looks like and where it comes from.
3.  **Domain/Logic Layer:** Implement the business rules and core functionalities.
4.  **Presentation Layer:** Build the UI that the user interacts with.

---

## 📝 The Development Workflow: A Detailed Breakdown

### Phase 1: The Foundation (Core Setup)

**Why we do this first:** Before writing any feature-specific code, we need to establish the rules, tools, and configurations that the entire app will share. This prevents repetition and ensures consistency. It's like laying the foundation and plumbing of a house before putting up the walls.

**What we will create:**

- **Dependencies (`pubspec.yaml`):** Add all necessary packages (GetX, Dio, Isar, etc.) to have our tools ready.
- **Configuration (`lib/app/config/`):**
  - `theme_config.dart`: Defines the app's visual style (colors, fonts, light/dark modes).
  - `api_config.dart`: Centralizes all API endpoints and base URLs.
  - `app_config.dart`: Holds app-wide constants like app name or version.
  - `cache_config.dart`: Specifies rules for caching, like storage limits.
- **Core Utilities (`lib/app/core/`):**
  - `utils/`: Reusable helper functions like `logger.dart`, `formatters.dart`, `network_utils.dart`, and `file_utils.dart`.
  - `constants/`: App-wide constants like API keys, database table names, etc.
  - `exceptions/`: Custom exception classes (`ApiException`, `CacheException`) for predictable error handling.
  - `mixins/`: Reusable code blocks for controllers, like `ErrorHandlerMixin` to handle errors consistently.

### Phase 2: The Data Layer (Models, Database, and API)

**Why we do this next:** The Data Layer is responsible for all data operations. We define it early because every feature in the app will depend on fetching, storing, or manipulating data. This layer is completely independent of the UI.

**What we will create:**

- **Models (`lib/app/data/models/`):**
  - These are the Dart classes that represent the data from your API (e.g., `SongModel`, `UserModel`, `PlaylistModel`). They include methods for converting JSON to Dart objects (`fromJson`) and back (`toJson`).
- **Data Sources (`lib/app/data/datasources/`):**
  - **Remote (`remote/`):** Classes that directly communicate with the backend API. We'll create `api_client.dart` (a configured Dio instance) and specific API classes like `auth_api.dart`, `songs_api.dart`, etc.
  - **Local (`local/`):** Classes that manage the local database. This includes `isar_database.dart` for setup and `cache_manager.dart` for handling offline storage logic (like saving a song or playlist).
- **Mappers (`lib/app/data/mappers/`):** Small, simple classes that convert data from one form to another (e.g., from a `SongModel` to a `SongEntity`). This separates our network data from our business logic.
- **Repositories (`lib/app/data/repositories/`):**
  - These classes are the single source of truth for the app's data. A repository will decide whether to fetch data from the API (remote) or the local database (local). For example, `SongRepository` might have a `getSongDetails` method that first checks the Isar cache and, if the song isn't there, fetches it from the `SongsApi`.

### Phase 3: The Domain & Services Layer (Business Logic)

**Why we do this next:** Now that we have a reliable way to get data, we can define the core business logic and services of the app. These are the "brains" of the application and are independent of the UI.

**What we will create:**

- **Entities (`lib/app/domain/entities/`):**
  - These are the core business objects of our app (e.g., `SongEntity`, `UserEntity`). They are clean, simple classes that represent the essential data needed for the app's features, without any JSON or database-specific code.
- **Use Cases (`lib/app/domain/usecases/`):**
  - Each use case represents a single business action, like `LoginUserUseCase` or `GetRecommendedSongsUseCase`. They use repositories to get data and contain the core logic for that action.
- **Services (`lib/services/`):**
  - These are singleton classes that manage long-running tasks or provide app-wide functionality. This is the perfect place for `AudioPlayerService` (to manage `just_audio`), `NetworkService` (to check connectivity), and `AnalyticsService`. They are initialized once and can be accessed from anywhere.

### Phase 4: The Presentation Layer (UI, State, and Routing)

**Why we do this last:** With the foundation, data, and logic in place, we can now build the user interface. The UI layer's only job is to display data and capture user input, delegating all the hard work to the controllers and services we've already built.

**What we will create:**

- **Routing (`lib/app/routes/`):**
  - `app_routes.dart`: Defines constant names for all our pages (e.g., `const HOME = '/home';`).
  - `app_pages.dart`: Links the route names to the actual screen widgets and their controller bindings.
- **Bindings (`lib/app/bindings/`):**
  - These GetX classes handle dependency injection. For example, `HomeBinding` will tell GetX to create an instance of `HomeController` when the user navigates to the home screen. `InitialBinding` will set up the core services and repositories when the app starts.
- **Controllers (`lib/app/presentation/controllers/`):**
  - This is where the state for each screen lives. The `AuthController` will manage the user's login state, and the `SongsController` will manage the list of songs. Controllers take user input (like a button press), call the appropriate use case or service, and update their state variables. The UI then automatically rebuilds to reflect the new state.
- **Screens (`lib/app/presentation/screens/`):**
  - These are the actual pages of the app, like `login_screen.dart`, `home_screen.dart`, and `player_screen.dart`. They are composed of widgets and use `Obx(() => ...)` to listen for state changes in their controller and update the UI accordingly.
- **Widgets (`lib/app/presentation/widgets/`):**
  - Reusable UI components like `SongTile`, `MiniPlayer`, or a custom app bar. This keeps the screen code clean and organized.

---

## ✅ Final Implementation Checklist

This is the step-by-step order of implementation:

1.  **Setup Project:** Initialize Flutter, set up `pubspec.yaml`, and run `flutter pub get`.
2.  **Build the Foundation:** Create all files under `app/config` and `app/core`.
3.  **Implement the Data Layer:**
    - Define all models in `app/data/models`.
    - Set up `api_client.dart` and `isar_database.dart`.
    - Implement all remote and local data sources.
    - Define repository interfaces and their implementations.
4.  **Implement the Domain & Services Layer:**
    - Define all entities in `app/domain/entities`.
    - Create services like `AudioPlayerService`.
    - Create use cases for business logic.
5.  **Set up the Presentation Foundation:**
    - Define all routes in `app_routes.dart` and `app_pages.dart`.
    - Create the `InitialBinding` to inject repositories and services.
6.  **Build Feature by Feature:** For each feature (e.g., Auth, Home, Player):
    - Create the `Controller` (e.g., `AuthController`).
    - Create the `Binding` (e.g., `AuthBinding`).
    - Build the `Screen` (e.g., `LoginScreen`).
    - Connect the screen to the controller, and the controller to the services/use cases.
7.  **Integrate Offline Caching:** Implement the logic in the repositories to save data to Isar and retrieve it when the device is offline.
8.  **Polish and Test:** Refine the UI, handle all loading and error states, and write tests for controllers and services.
