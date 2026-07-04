# Pokopia

A native iOS Pokédex and map-assignment app built with SwiftUI, SQLite, and MVVM architecture.

## Features

- Browsable and searchable Pokédex with 303 Pokémon
- Filter by type, specialty, favorite, and environment (multi-select)
- Map assignment system: assign each Pokémon to one of 5 in-game maps (or leave unassigned)
- Local persistence with SQLite (via native `libsqlite3`)

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Database**: SQLite (system `libsqlite3` with bridging header)


## Project Structure

\`\`\`
PokopiaApp/
├── Models/          # Data models (Pokemon, GameMap, TypeColors)
├── Data/            # SQLite database setup
├── Repositories/     # CRUD and query logic
├── ViewModels/       # State management (MVVM)
├── Views/            # SwiftUI views
└── Resources/        # JSON data and image assets
\`\`\`

## Status

🚧 In progress — actively being developed as part of iOS learning.
