# GameSource

A minimal SwiftUI app that shows your Steam library using the official Steam Web API.

This is a simplified version of [GameSource](https://github.com/EnzoFerroni/GameSource), focused on the essentials: declarative SwiftUI, MVVM architecture and RESTful API consumption.

## Features

- Browse your Steam library, sorted by most played
- Search games by name
- Game detail screen with playtime and a link to the Steam Store
- Loading, error and empty states with pull to refresh and retry

## Architecture (MVVM)

```
GameSource/
├── App/            Entry point (GameSourceApp)
├── Models/         Codable structs mirroring the Steam API (SteamGame)
├── Services/       API layer (SteamService) behind a protocol (GameFetching)
├── ViewModels/     Screen state and logic (GameLibraryViewModel)
└── Views/          SwiftUI views (Library, Row, Detail)
```

- **View** reads `@Published` state from the view model and forwards user actions.
- **ViewModel** is `@MainActor` and owns all screen state; the service is injected via protocol, so it can be replaced by a fake in tests.
- **Service** builds URLs with `URLComponents`, uses `async/await` and decodes with `convertFromSnakeCase`.

## Running

1. Get a Steam Web API key at <https://steamcommunity.com/dev/apikey>.
2. Find your 64-bit SteamID at <https://steamid.io> (your profile must be public).
3. Open `GameSource/Secrets.xcconfig` and fill in `STEAM_API_KEY` and `STEAM_ID`.
4. Open `GameSource.xcodeproj` and run.

> `Secrets.xcconfig` is gitignored, so keys never reach the repository. The values are injected into the app at build time via `Info.plist`.
