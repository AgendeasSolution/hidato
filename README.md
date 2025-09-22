# Hidato Puzzle Game

A challenging Hidato puzzle game built with Flutter, featuring a clean and maintainable codebase following Flutter best practices.

## 🎮 Game Features

- **Multiple Levels**: 5 progressively challenging levels
- **Smart Hints**: Get hints when you're stuck
- **Solution Solver**: View complete solutions
- **Undo/Reset**: Full game state management
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Beautiful UI**: Modern, clean interface with smooth animations

## 🏗️ Project Structure

The project follows Flutter best practices with a well-organized folder structure:

```
lib/
├── constants/          # App-wide constants and configuration
│   ├── app_colors.dart     # Color scheme definitions
│   ├── app_constants.dart  # App constants and configuration
│   ├── level_data.dart     # Predefined puzzle levels
│   └── index.dart          # Exports all constants
├── models/             # Data models and classes
│   ├── position.dart       # Position model for board coordinates
│   ├── game_state.dart     # Game state management
│   ├── level_config.dart   # Level configuration model
│   ├── solver_models.dart  # Solver-related data models
│   └── index.dart          # Exports all models
├── screens/            # UI screens
│   └── game_screen.dart    # Main game screen
├── services/           # Business logic and external services
│   ├── game_solver.dart    # Puzzle solving algorithms
│   ├── game_validator.dart # Game validation logic
│   ├── hint_service.dart   # Hint generation service
│   └── index.dart          # Exports all services
├── utils/              # Utility functions and helpers
│   ├── responsive_utils.dart # Responsive design utilities
│   ├── game_utils.dart      # Game logic utilities
│   └── index.dart           # Exports all utilities
├── widgets/            # Reusable UI components
│   ├── game_cell.dart       # Individual game board cell
│   ├── game_button.dart     # Custom button components
│   ├── game_popup.dart      # Popup dialog components
│   └── index.dart           # Exports all widgets
├── theme/              # App theming
│   └── app_theme.dart      # Light and dark theme definitions
└── main.dart           # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd hidato
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## 🎯 How to Play

1. **Objective**: Fill the grid with consecutive numbers from start to end
2. **Rules**:
   - Numbers must be adjacent (horizontally or vertically)
   - Start from the lowest number and work your way up
   - Use the hint button if you get stuck!
3. **Controls**:
   - Tap empty cells to place numbers
   - Use hints to get help
   - Reset to start over
   - Undo to go back one move

## 🛠️ Architecture

### Design Patterns

- **MVC Pattern**: Clear separation of concerns
- **Service Layer**: Business logic separated from UI
- **Widget Composition**: Reusable, composable UI components
- **Dependency Injection**: Services injected where needed

### Key Features

- **Responsive Design**: Adapts to different screen sizes
- **State Management**: Efficient state handling with setState
- **Animation Support**: Smooth animations and transitions
- **Error Handling**: Comprehensive error handling and validation
- **Performance**: Optimized rendering and memory usage

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 Customization

### Colors

Modify colors in `lib/constants/app_colors.dart`

### Levels

Add new levels in `lib/constants/level_data.dart`

### Themes

Customize themes in `lib/theme/app_theme.dart`

## 🧪 Testing

Run tests with:

```bash
flutter test
```

## 📦 Dependencies

- `flutter`: Flutter SDK
- `cupertino_icons`: iOS-style icons
- `google_fonts`: Custom font support
- `confetti`: Celebration animations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The puzzle community for inspiration
- Contributors and testers

---

**Happy Puzzling! 🧩**
