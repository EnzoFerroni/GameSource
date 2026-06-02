# GameSource

App iOS/macOS em SwiftUI que autentica via Steam OpenID, exibe a biblioteca de jogos do usuário e mostra as conquistas de cada jogo.

## Requisitos

- Xcode 15+
- Uma chave da Steam Web API: https://steamcommunity.com/dev/apikey

## Como rodar

1. Clone o repositório:
   ```bash
   git clone https://github.com/EnzoFerroni/GameSource
   cd GameSource
   ```

2. Crie o arquivo de chaves a partir do template:
   ```bash
   cp GameSource/GameSource/APIKeys.plist.template GameSource/GameSource/APIKeys.plist
   ```

3. Abra `GameSource/GameSource/APIKeys.plist` e substitua `YOUR_STEAM_API_KEY_HERE` pela sua chave da Steam Web API.

   > `APIKeys.plist` está no `.gitignore` — sua chave nunca é commitada.

4. Abra o projeto no Xcode:
   ```bash
   open GameSource/GameSource.xcodeproj
   ```

5. Selecione um simulador (ou seu dispositivo) e rode com `Cmd+R`.

## Estrutura

- `ViewModels/` — `AuthViewModel` (login Steam OpenID) e `GamesViewModel` (biblioteca, filtros, busca).
- `Services/` — `SteamService` (chamadas à Steam Web API), `APIConfiguration` (lê `APIKeys.plist`).
- `Models/` — structs `Codable` que mapeiam as respostas da Steam API.
- `Views/` — telas e componentes SwiftUI.
