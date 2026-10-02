# MétéoNow — Connected Weather App (Design Spec)

**Date:** 2026-10-03
**Author:** Yannick Ouedraogo (with Claude)
**Context:** NextFlutter certification project "Flutter Project — Connected app with real backend" (course: Network Calls and APIs, 7/7 completed, Advanced). Requires score ≥ 70/100. Submission is a public GitHub repo with a README explaining architecture, APIs used, and configuration steps.

**Delivery constraint:** this repo (`github.com/LEVI226/meteonow`) must never be pushed to by the assistant, under any circumstances, per the user's standing instruction. The user pushes it themselves when ready.

## Grading requirements (verbatim from the course)

- Authentication (login/register/logout) — JWT or OAuth
- At least 3 screens with data from a REST API
- Local data caching (Hive, Isar or SQLite)
- Offline mode: show cached data when no network
- Network error handling with user messages
- Clean Architecture (data/domain/presentation) or Feature-First
- Repository pattern for data access
- Dio or http for network calls
- Interceptor for auth token injection
- Refresh token handling (if applicable)
- At least 3 unit tests on the repository layer
- Delivery: public GitHub repo with README explaining architecture, APIs used, and configuration steps

## Design source

The user designed the UI in Google Stitch and exported it to `stitch_m_t_onow_mobile_app_design/` (sibling of this `docs/` folder): `m_t_onow_login/`, `home_live_weather/`, `search_locations/`, `favorites_locations/` (each with `code.html` + `screen.png`), plus `atmosphere_minimal/DESIGN.md` (design tokens) and a standalone app logo image. No Register or Profile screen was exported — those are designed in this spec, matching the exported screens' style.

The exported HTML itself specifies the backend choices used throughout this spec: the Home screen's footer reads "Open-Meteo REST API via Dio", the Login screen has a badge reading "Supabase Auth • Dio HTTP • JWT", and the Favorites screen notes "Saved in Local Hive / Isar Cache for offline access" — all confirmed with the user during brainstorming, not assumed.

## Topic

**MétéoNow**: check live weather and forecasts for any city worldwide, search and bookmark favorite locations (synced to your account), and manage your profile — built to demonstrate a real authenticated backend, a public weather API, local caching, and offline mode.

## APIs

- **Open-Meteo** (`api.open-meteo.com`, `geocoding-api.open-meteo.com`) — weather data and city geocoding. Free, no API key, no registration. Used for: current conditions, hourly forecast, 5-day forecast, and city name search.
- **Supabase** — authentication (email/password + Google OAuth) via the `supabase_flutter` SDK, and a `favorites` Postgres table (accessed via Supabase's REST/PostgREST endpoint through a hand-rolled Dio client) for cross-device favorite-location sync. The user has not created a Supabase project yet — the implementation plan includes the exact setup steps (project creation, `favorites` table schema, Row Level Security policy, retrieving the project URL and anon key).

## Package / naming

- Dart package name: `meteonow`
- App display title: "MétéoNow"
- Project root: this directory (`meteonow`), its own git repository, **never pushed to `origin` by the assistant**.
- Platforms: android, web, windows (the three verified-working targets on this machine, same as the prior certification project).

## Design tokens (from `atmosphere_minimal/DESIGN.md`)

As with the prior certification project's Stitch export, this DESIGN.md has a YAML front-matter token block and a prose "Colors" section that disagree (the prose describes `#0284C7`/`#0F172A`/`#10B981`; the YAML and the actual HTML/Tailwind config use `#006194`/`#565e74`/`#006947`). **The YAML front-matter is ground truth** — verified identical across all 4 exported `code.html` files' embedded Tailwind config — so this spec follows the YAML tokens.

- **Font:** Inter (via `google_fonts`), weights 300/400/500/600, matching the display-hero/headline/body/label scale in DESIGN.md.
- **Light `ColorScheme`:** built from the YAML tokens — `primary #006194`, `secondary #565e74`, `tertiary #006947`, `surface #f7f9fb`, `error #ba1a1a`, plus their `on-*`/container variants.
- **Dark `ColorScheme`:** generated via `ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark)` — no dark variant was exported, same pragmatic approach as the prior project.
- **Shape:** cards 16px radius, buttons/inputs 12px radius, pills/chips fully rounded — matches DESIGN.md's `rounded` scale.
- **Spacing:** 4/8/16/24/32px scale (DESIGN.md's `space-xs` → `space-xl`).

## Architecture — Feature-First + Clean Architecture

```
meteonow/
├── lib/
│   ├── main.dart                        # app bootstrap: Hive.init, Supabase.initialize, runApp
│   ├── core/
│   │   ├── network/
│   │   │   ├── open_meteo_client.dart   # plain Dio instance, no auth, base URLs for forecast + geocoding
│   │   │   ├── supabase_rest_client.dart# Dio instance for Supabase PostgREST calls
│   │   │   └── auth_interceptor.dart    # injects the current Supabase access token + apikey header; retries once after a 401 by refreshing the session
│   │   ├── cache/
│   │   │   └── hive_boxes.dart          # Hive.initFlutter, box names/open calls, adapter registration
│   │   ├── theme/
│   │   │   └── app_theme.dart           # light/dark ColorScheme, Inter text theme, shapes
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter: auth-gated redirect, ShellRoute with 4 tabs, /login, /register
│   │   └── errors/
│   │       ├── app_failure.dart         # sealed Failure types: NetworkFailure, AuthFailure, CacheFailure
│   │       └── result.dart              # Result<T> (success/failure) wrapper returned by every repository method
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/auth_repository_impl.dart       # wraps supabase_flutter's auth client
│   │   │   ├── domain/{auth_repository.dart, app_user.dart}
│   │   │   └── presentation/{login_screen.dart, register_screen.dart, auth_controller.dart}
│   │   ├── weather/
│   │   │   ├── data/{open_meteo_api.dart, weather_local_data_source.dart (Hive), weather_repository_impl.dart}
│   │   │   ├── domain/{weather_repository.dart, current_weather.dart, hourly_forecast.dart, daily_forecast.dart, geocoded_location.dart}
│   │   │   └── presentation/{home_screen.dart, search_screen.dart, weather_controller.dart}
│   │   ├── favorites/
│   │   │   ├── data/{favorites_remote_data_source.dart (Dio+Supabase REST), favorites_local_data_source.dart (Hive), favorites_repository_impl.dart}
│   │   │   ├── domain/{favorites_repository.dart, favorite_location.dart}
│   │   │   └── presentation/{favorites_screen.dart, favorites_controller.dart}
│   │   └── profile/
│   │       ├── data/settings_local_data_source.dart  # Hive-backed theme mode + temperature unit
│   │       ├── domain/app_settings.dart
│   │       └── presentation/profile_screen.dart
│   └── shared/
│       └── widgets/{weather_metric_chip.dart, forecast_day_tile.dart, location_card.dart, sync_status_pill.dart}
├── test/
│   ├── features/weather/data/weather_repository_impl_test.dart
│   ├── features/favorites/data/favorites_repository_impl_test.dart
│   └── features/auth/data/auth_repository_impl_test.dart
├── analysis_options.yaml
└── README.md
```

`shared/widgets/` holds the reusable presentational widgets (status pills, metric chips, forecast tiles, location cards) used across the weather and favorites features — not nested inside a single feature since both Home/Search and Favorites reuse them.

## Navigation (GoRouter)

- `redirect`: checks `Supabase.instance.client.auth.currentSession`. No session → redirect to `/login` (except when already on `/login` or `/register`). Has a session and is on `/login`/`/register` → redirect to `/`.
- Outside any shell: `/login` → `LoginScreen`, `/register` → `RegisterScreen`.
- `ShellRoute` (adaptive bottom `NavigationBar`, 4 tabs — no tablet/`NavigationRail` requirement in this rubric, unlike the prior project, so a single mobile-first layout is sufficient):
  - `/` → `HomeScreen`
  - `/search` → `SearchScreen`
  - `/favorites` → `FavoritesScreen`
  - `/profile` → `ProfileScreen`

## Auth

- `supabase_flutter` handles `signInWithPassword`, `signUp`, `signInWithOAuth(OAuthProvider.google)`, `signOut`, and session/JWT refresh internally — this is the realistic, idiomatic way to use Supabase auth; hand-rolling the GoTrue protocol would be reinventing a well-tested wheel.
- The router's redirect listens to `Supabase.instance.client.auth.onAuthStateChange` to react immediately to login/logout.
- **`AuthInterceptor`** (the rubric's "interceptor for auth token injection" + "refresh token handling") applies specifically to the `supabase_rest_client` Dio instance used for Favorites: on each request it reads `auth.currentSession?.accessToken`, attaches `Authorization: Bearer <token>` and the project's `apikey` header; on a `401` response it calls `auth.refreshSession()` once and retries the original request, surfacing an `AuthFailure` (triggering a redirect to `/login`) only if the refresh itself fails. Open-Meteo's `open_meteo_client` has no interceptor — it's a public, unauthenticated API, and adding one would be YAGNI.

## Data layer & offline mode

- **Weather**: `OpenMeteoApi` wraps the forecast endpoint (current + hourly + daily in one call, per Open-Meteo's API) and the geocoding endpoint (city name → lat/lon). `WeatherRepositoryImpl` tries the network call first; on success, caches the parsed result in Hive keyed by `"lat,lon"` with a timestamp; on a `DioException` (timeout/no connection), it falls back to the last cached entry for that location (if any) and returns it wrapped with a `isFromCache: true` flag the UI uses to show the amber "Cached" pill from the Stitch design — matching `favorites_locations`' "Live" vs. the design system's documented "Cached Data Pill" component.
- **Favorites**: `FavoritesRepositoryImpl` writes/reads through `FavoritesRemoteDataSource` (Supabase REST via the intercepted Dio client) and mirrors every successful write to `FavoritesLocalDataSource` (Hive). Reads try remote first, falling back to the Hive mirror on failure — same offline pattern as weather, satisfying "offline mode: show cached data when no network" for both data types the app has.
- **Settings** (theme mode, temperature unit): Hive only, no backend — this is local device preference, not something that needs syncing.
- **Error handling**: every repository method returns `Result<T>` (success or a typed `Failure`), never throws past the data layer. Presentation layer maps `Failure` to a user-facing message (`SnackBar` or the Stitch design's red offline banner), never shows a raw exception/stack trace.

## Screens

1. **Login** (`/login`) — Stitch: `m_t_onow_login`. Email + password fields (validated: required, email format, password non-empty), "Forgot password?" (shows a snackbar — password reset email flow is out of scope, see below), primary "Log in" button, "Continue with Google" OAuth button, footer link to `/register`.
2. **Register** (`/register`) — own design matching Login's card layout: name, email, password, confirm-password fields (validated: all required, email format, passwords match, password ≥ 6 chars per Supabase's default minimum), primary "Create account" button, footer link back to `/login`.
3. **Home** (`/`) — Stitch: `home_live_weather`. Greeting + current location name, live-sync pill + refresh button, hero card (temperature, condition, "feels like", 4 metric chips: humidity/wind/pressure/visibility), 24-hour horizontal forecast rail, 5-day forecast list, offline/cached banner when applicable.
4. **Search** (`/search`) — Stitch: `search_locations`. Search field (debounced query to Open-Meteo's geocoding endpoint), result cards (name, region/country, current condition fetched per result, favorite-toggle bookmark button). The Stitch design's decorative "Radar & Satellite View" map preview is a static illustrative card, not a real map integration — out of scope (see below).
5. **Favorites** (`/favorites`) — Stitch: `favorites_locations`. List of saved locations with live conditions, last-updated timestamp, sync-all button, FAB linking to `/search` to add a new one, offline-cached indicator per card when applicable.
6. **Profile** (`/profile`) — own design: account email (from the Supabase session), logout button; a °C/°F segmented toggle (persisted via the settings Hive box, read by Home/Search/Favorites when formatting temperatures); a light/dark theme switch (same pattern as the prior certification project); a small local-stats section (favorite count, last sync time) derived from existing data, not a new source.

## Reusable widgets (in `lib/shared/widgets/`)

1. `WeatherMetricChip` — icon + label + value, used for humidity/wind/pressure/visibility on Home and in location cards.
2. `ForecastDayTile` — a single day's row in the 5-day forecast list.
3. `LocationCard` — a search result or favorite location's summary card (name, condition, temperature, favorite toggle) — reused across Search and Favorites.
4. `SyncStatusPill` — the "Live"/"Cached"/"Offline" indicator component described in DESIGN.md's "Status Badges & Sync Banners" section.

## Testing

Minimum 3 unit tests on the repository layer (rubric requirement), implemented as:

- `weather_repository_impl_test.dart` — a successful fetch caches the result; a simulated `DioException` falls back to a previously cached entry and marks it `isFromCache`.
- `favorites_repository_impl_test.dart` — adding a favorite writes through to the mocked remote data source and mirrors to the local one; a simulated remote failure still returns the local mirror's list.
- `auth_repository_impl_test.dart` — login success maps to an `AppUser`; login failure (invalid credentials) maps to an `AuthFailure`, not an uncaught exception.

Dio calls are mocked (no real network in tests); Hive uses a temporary in-memory/test box, not the real app data directory.

## Delivery

- `analysis_options.yaml` using `package:lints/recommended.yaml`, same convention as the prior project.
- `README.md`: description, architecture overview (Feature-First + Clean Architecture diagram), the two APIs used and why, step-by-step configuration (creating a Supabase project, the `favorites` table SQL + RLS policy, where to put the Supabase URL/anon key — via `--dart-define` or a gitignored config file, never committed in plaintext), how to run, and a requirements-traceability table mapping each rubric line item to the screen/file that satisfies it (the technique that measurably helped the prior project score 99/100).
- Git: this directory is its own repository. **Never pushed by the assistant** — the user pushes when ready.

## Explicitly out of scope (YAGNI)

- Real password-reset email flow — "Forgot password?" shows a snackbar acknowledging the tap; wiring Supabase's actual reset-email flow adds SMTP/template configuration out of proportion to the rubric's requirements.
- A real interactive map/radar view on Search — the Stitch design's map card is decorative; implementing real radar tile imagery would require a third API/service not otherwise needed.
- Tablet/responsive layout — not a requirement of this course's rubric (unlike the prior one).
- Push notifications, background weather refresh, widgets/home-screen widgets — none required by the rubric.
- Multi-language/localization — not required.
