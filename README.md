# ♟️ Chess — Flutter

A cross-platform chess game built with **Flutter**, featuring an interactive board, draggable pieces, smooth animations, and both **solo AI** and **local two-player** gameplay.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-WIP-orange?style=for-the-badge)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-1e1e2e?style=for-the-badge)

> 🚧 **Work in progress** — features are actively being built and improved.

---

## ✨ Features

| Feature | Description |
|---|---|
| ♟️ Interactive Board | Draggable pieces with legal move highlighting |
| 🤖 vs AI | Single-player mode against a chess engine via API |
| 👥 Local Multiplayer | Two-player mode on the same device |
| 🔊 Sound Effects | Audio feedback for moves, captures, and check |
| 🎉 Win Celebration | Confetti animation on game end |
| 📊 Game Analysis | Post-game review screen |
| 🏳️ Resignation | Option to forfeit mid-game |
| ⚖️ Stalemate Detection | Automatic stalemate recognition and display |
| 🎨 Theme Support | App-wide light and dark theming |
| ⚙️ Settings | Persistent user preferences across sessions |

---

## 📦 Tech Stack

| Package | Version | Purpose |
|---|---|---|
| `audioplayers` | ^6.1.0 | Move & game-event sound effects |
| `confetti` | ^0.8.0 | Win celebration animation |
| `shared_preferences` | ^2.3.3 | Persist settings across sessions |
| `http` | ^1.1.0 | External chess API integration |
| `cupertino_icons` | ^1.0.8 | iOS-style icon support |

---

## 📁 Structure

```
lib/
├── main.dart                     # App entry point
├── splash_screen.dart            # Launch screen
├── login_screen.dart             # Player selection / login
├── game_board.dart               # Core board logic & UI
├── game_analysis_screen.dart     # Post-game review
├── resignation_screen.dart       # Resign flow
├── stalemate_screen.dart         # Stalemate result display
├── win_celebration_screen.dart   # Confetti win screen
├── settings_screen.dart          # App settings
├── sound_manager.dart            # Audio service
├── chess_api_service.dart        # Chess API calls (AI mode)
├── theme_provider.dart           # Theme management
├── components/                   # Shared UI widgets
├── helper/                       # Utility & game-logic helpers
├── images/                       # Piece & board image assets
└── values/                       # App-wide constants
```

```
assets/
└── sounds/                       # Audio files for game events
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=2.19.0 <4.0.0`
- Dart SDK *(bundled with Flutter)*
- Android Studio or VS Code with the Flutter plugin
- A physical device or emulator

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Suyog0-0/Chess.git
cd Chess

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web

# Windows
flutter build windows
```

---

## 🖥️ Platform Support

| Platform | Status |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

---

## 🗺️ Roadmap

- [ ] Improved AI difficulty levels
- [ ] Move history & PGN export
- [ ] Online multiplayer
- [ ] Chess clock / timer modes
- [ ] Opening explorer

---

## 📝 Notes

- Piece images and board assets live in `lib/images/`
- Sound files are stored under `assets/sounds/`
- User preferences are persisted via `shared_preferences`
- AI gameplay is powered by an external chess API (`chess_api_service.dart`)

---

*Built as a hands-on learning project to explore Flutter's widget system, state management, and game logic implementation.*
