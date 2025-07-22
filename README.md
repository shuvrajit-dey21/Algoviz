# AlgoViz - Algorithm Visualizer

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white" alt="Material Design">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</div>

<div align="center">
  <h3>🚀 Interactive Algorithm & Data Structure Visualizer</h3>
  <p><em>Visualize. Learn. Master.</em></p>
</div>

---

## 📖 Overview

**AlgoViz** is a comprehensive Flutter-based mobile and web application designed to help students, developers, and computer science enthusiasts visualize and understand algorithms and data structures through interactive animations and step-by-step demonstrations.

### ✨ Key Features

- 🎯 **Interactive Visualizations**: Real-time algorithm execution with animated step-by-step breakdowns
- 🌓 **Dual Theme Support**: Beautiful light and dark themes with smooth transitions
- 📱 **Cross-Platform**: Runs seamlessly on Android, iOS, Web, Windows, macOS, and Linux
- 🔐 **User Authentication**: Secure login system with social authentication options
- 📊 **Comprehensive Coverage**: Wide range of algorithms and data structures
- 🎨 **Modern UI/UX**: Material Design 3 with custom animations and particle effects
- 📈 **Progress Tracking**: Save and track your learning progress
- 🔍 **Smart Search**: Quick algorithm and concept lookup functionality

## 🏗️ Architecture & Structure

### Project Structure
```
lib/
├── algorithms/          # Algorithm implementations and visualizers
│   ├── sorting_visualizer.dart
│   ├── search_visualizer.dart
│   ├── binary_search_tree.dart
│   ├── graph_traversal.dart
│   └── ...
├── pages/              # Main application pages
│   ├── dashboard_page.dart
│   ├── login_page.dart
│   ├── profile_page.dart
│   └── ...
├── screens/            # Screen components
│   ├── auth/
│   └── profile/
├── widgets/            # Reusable UI components
│   ├── animated_background.dart
│   ├── navigation_drawer.dart
│   └── ...
├── providers/          # State management
│   ├── theme_provider.dart
│   └── user_provider.dart
├── models/             # Data models
├── services/           # Business logic and API services
├── theme/              # Theme configuration
├── utils/              # Utility functions
└── routes/             # Navigation routes
```

## 🎯 Supported Algorithms & Data Structures

### 🔄 Sorting Algorithms
- **Bubble Sort** - Simple comparison-based sorting
- **Selection Sort** - In-place comparison sorting
- **Insertion Sort** - Builds sorted array one item at a time
- **Merge Sort** - Divide-and-conquer approach
- **Quick Sort** - Efficient divide-and-conquer sorting
- **Heap Sort** - Comparison-based using binary heap

### 🔍 Searching Algorithms
- **Linear Search** - Sequential search through elements
- **Binary Search** - Efficient search in sorted arrays
- **Depth-First Search (DFS)** - Graph traversal algorithm
- **Breadth-First Search (BFS)** - Level-order graph traversal

### 🌳 Data Structures
- **Arrays & Lists** - Dynamic array operations
- **Linked Lists** - Singly, doubly, and circular linked lists
- **Stacks** - LIFO (Last In, First Out) operations
- **Queues** - FIFO (First In, First Out) operations
- **Binary Trees** - Tree structure with binary nodes
- **Binary Search Trees** - Ordered binary tree structure
- **Graphs** - Vertex and edge relationships

### 🛣️ Graph Algorithms
- **Shortest Path** - Dijkstra's and Floyd-Warshall algorithms
- **Minimum Spanning Tree** - Kruskal's and Prim's algorithms
- **Graph Traversal** - DFS and BFS implementations

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 2.17.0 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platform-specific requirements**:
  - Android: Android Studio and Android SDK
  - iOS: Xcode (macOS only)
  - Web: Chrome browser
  - Desktop: Platform-specific build tools

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shuvrajit-dey21/algoviz.git
   cd algoviz
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For mobile/desktop
   flutter run

   # For web
   flutter run -d chrome

   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.5              # State management
  google_fonts: ^6.1.0          # Custom fonts
  animated_background: ^2.0.0   # Background animations
  shared_preferences: ^2.2.3    # Local storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  url_launcher: ^6.2.4          # External URL handling
  package_info_plus: ^5.0.1     # App information
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0         # Linting rules
```

## 🎨 Features in Detail

### 🔐 Authentication System
- **Secure Login/Registration**: Email and password authentication
- **Social Login**: Google and Facebook integration (ready for implementation)
- **Session Management**: Persistent login with secure storage
- **User Profiles**: Customizable user profiles with progress tracking

### 🎯 Interactive Visualizations
- **Real-time Animation**: Watch algorithms execute step-by-step
- **Speed Control**: Adjust animation speed for better understanding
- **Input Customization**: Use custom datasets or generate random data
- **Step-by-step Breakdown**: Detailed explanation of each algorithm step
- **Complexity Analysis**: Time and space complexity information

### 🌟 User Experience
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Navigation Rail**: Desktop-optimized navigation with collapsible sidebar
- **Mobile Drawer**: Touch-friendly navigation for mobile devices
- **Search Functionality**: Quick access to algorithms and concepts
- **Theme Switching**: Seamless light/dark mode transitions
- **Particle Effects**: Beautiful animated backgrounds and visual effects

### 📊 Learning Tools
- **Progress Tracking**: Monitor your learning journey
- **Favorites System**: Save frequently used algorithms
- **Help Center**: Comprehensive documentation and tutorials
- **Settings Panel**: Customize app behavior and preferences

## 🛠️ Technical Implementation

### State Management
- **Provider Pattern**: Efficient state management using Provider package
- **Theme Management**: Centralized theme switching and persistence
- **User State**: Authentication and user data management

### UI/UX Design
- **Material Design 3**: Latest Material Design principles
- **Custom Animations**: Smooth transitions and micro-interactions
- **Responsive Layout**: Adaptive UI for different screen sizes
- **Accessibility**: Screen reader support and keyboard navigation

### Performance Optimization
- **Lazy Loading**: Efficient memory usage with on-demand loading
- **Animation Controllers**: Optimized animation performance
- **RepaintBoundary**: Reduced unnecessary widget rebuilds
- **Efficient Rendering**: Custom painters for complex visualizations

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Test Structure
- **Widget Tests**: UI component testing
- **Unit Tests**: Algorithm logic testing
- **Integration Tests**: End-to-end functionality testing

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | API 21+ (Android 5.0+) |
| iOS | ✅ Full Support | iOS 11.0+ |
| Web | ✅ Full Support | Modern browsers |
| Windows | ✅ Full Support | Windows 10+ |
| macOS | ✅ Full Support | macOS 10.14+ |
| Linux | ✅ Full Support | Ubuntu 18.04+ |

## 🔧 Configuration

### Environment Setup
1. **Flutter Environment Variables**
   ```bash
   export FLUTTER_ROOT=/path/to/flutter
   export PATH=$PATH:$FLUTTER_ROOT/bin
   ```

2. **IDE Configuration**
   - Install Flutter and Dart plugins
   - Configure code formatting and linting
   - Set up debugging configurations

### App Configuration
- **Theme Settings**: Customize colors and typography in `lib/theme/`
- **Animation Settings**: Adjust animation speeds and effects
- **Feature Flags**: Enable/disable specific features for different builds

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute
- 🐛 **Bug Reports**: Report issues and bugs
- 💡 **Feature Requests**: Suggest new algorithms or features
- 📝 **Documentation**: Improve documentation and tutorials
- 🔧 **Code Contributions**: Add new algorithms or fix existing ones
- 🎨 **UI/UX Improvements**: Enhance the user interface and experience

### Development Workflow
1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/new-algorithm
   ```
3. **Make your changes**
4. **Add tests** for new functionality
5. **Run tests and ensure they pass**
   ```bash
   flutter test
   flutter analyze
   ```
6. **Commit your changes**
   ```bash
   git commit -m "Add: New sorting algorithm visualization"
   ```
7. **Push to your fork**
   ```bash
   git push origin feature/new-algorithm
   ```
8. **Create a Pull Request**

### Code Style Guidelines
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex algorithm logic
- Maintain consistent indentation (2 spaces)
- Run `flutter format .` before committing

## 📚 Learning Resources

### Algorithm Complexity Reference
| Algorithm | Best Case | Average Case | Worst Case | Space |
|-----------|-----------|--------------|------------|-------|
| Bubble Sort | O(n) | O(n²) | O(n²) | O(1) |
| Selection Sort | O(n²) | O(n²) | O(n²) | O(1) |
| Insertion Sort | O(n) | O(n²) | O(n²) | O(1) |
| Merge Sort | O(n log n) | O(n log n) | O(n log n) | O(n) |
| Quick Sort | O(n log n) | O(n log n) | O(n²) | O(log n) |
| Binary Search | O(1) | O(log n) | O(log n) | O(1) |

### Educational Content
- **Interactive Tutorials**: Step-by-step algorithm walkthroughs
- **Complexity Analysis**: Understanding time and space complexity
- **Real-world Applications**: Where these algorithms are used
- **Practice Problems**: Coding challenges and exercises

## 🔮 Roadmap

### Version 2.0 (Upcoming)
- [ ] **Advanced Graph Algorithms**: A*, Bellman-Ford, Topological Sort
- [ ] **Dynamic Programming**: Knapsack, LCS, Edit Distance
- [ ] **Machine Learning Algorithms**: Basic ML algorithm visualizations
- [ ] **Code Generation**: Export algorithm implementations in multiple languages
- [ ] **Collaborative Features**: Share visualizations and compete with friends

### Version 2.1 (Future)
- [ ] **AR/VR Support**: Immersive algorithm visualization
- [ ] **Voice Commands**: Navigate using voice controls
- [ ] **Offline Mode**: Full functionality without internet
- [ ] **Custom Algorithm Builder**: Create your own algorithm visualizations
- [ ] **Performance Benchmarking**: Compare algorithm performance

## 🐛 Known Issues

- [ ] **Web Performance**: Large datasets may cause performance issues on web
- [ ] **iOS Simulator**: Some animations may appear choppy on iOS simulator
- [ ] **Memory Usage**: High memory usage with complex graph visualizations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Material Design**: For the beautiful design system
- **Open Source Community**: For inspiration and contributions
- **Algorithm Educators**: For making computer science accessible
- **Beta Testers**: For valuable feedback and bug reports

## 

---

<div align="center">
  <p><strong>Made with ❤️ by the AlgoViz Team</strong></p>
  <p><em>Empowering the next generation of developers through visual learning</em></p>
</div>
