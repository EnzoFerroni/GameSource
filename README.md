# GameSource

A minimal SwiftUI app that shows your Steam library using the official Steam Web API.

This is a simplified version of [GameSource](https://github.com/EnzoFerroni/GameSource), focused on the essentials: declarative SwiftUI, MVVM architecture and RESTful API consumption.

## Features

- Sign in with Steam (real OpenID login), persisted across launches
- Browse your Steam library as a cover grid, with your profile in the toolbar
- Search, sort (playtime/name) and filter (all/played/unplayed)
- Game detail sheet with playtime, achievements and a Steam Store link
- Random game picker
- Daily notification suggesting an unplayed game
- Loading, error and empty states with pull to refresh and retry

## Architecture (MVVM)

```
GameSource/
├── App/            Entry point (GameSourceApp)
├── Models/         Codable structs mirroring the Steam API
├── Services/       SteamService (behind GameFetching), NotificationService
├── ViewModels/     One per screen (Auth, GameLibrary, GameDetail)
└── Views/          SwiftUI views (Login, Library, Card, Detail, Notifications)
```

- **View** reads `@Published` state from the view model and forwards user actions.
- **ViewModel** is `@MainActor` and owns all screen state; the service is injected via protocol, so it can be replaced by a fake in tests.
- **Service** builds URLs with `URLComponents`, uses `async/await` and decodes with `convertFromSnakeCase`.

## Running

1. Get a Steam Web API key at <https://steamcommunity.com/dev/apikey>.
2. Open `GameSource/Secrets.xcconfig` and fill in `STEAM_API_KEY`.
3. Open `GameSource.xcodeproj` and run.
4. Sign in with your Steam account (profile must be public).

> Steam's OpenID flow only redirects to http(s) URLs, so login goes through a small static page on GitHub Pages that bounces back into the app via the `loginsteam://` scheme.

> `Secrets.xcconfig` is gitignored, so keys never reach the repository. The values are injected into the app at build time via `Info.plist`.
