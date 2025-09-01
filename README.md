# 🦸 HeroTeam

A Flutter project for managing and creating Pokémon teams.  

## 🚀 Getting Started

Clone the repository and install dependencies:

```bash
flutter pub get
flutter run -d chrome
```
```
lib/
  ┣ models/ # Data models (Pokemon, Team, etc.)
  ┣ services/ # API and data services
  ┣ controllers/ # State management (GetX controllers)
  ┣ pages/ # UI pages (Home, Team Detail, etc.)
  ┣ storage/ # Local storage keys and helpers
  ┣ widgets/ # Reusable UI components
  ┗ main.dart # Entry point
```
```
graph TD
    A[lib] --> B[models]
    A --> C[services]
    A --> D[controllers]
    A --> E[pages]
    A --> F[storage]
    A --> G[widgets]
    A --> H[main.dart]
```
