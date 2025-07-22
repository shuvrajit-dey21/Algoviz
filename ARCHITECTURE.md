# 🏗️ AlgoViz Architecture & Structure

<div align="center">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-blue?style=for-the-badge" alt="Architecture">
  <img src="https://img.shields.io/badge/Pattern-Provider-green?style=for-the-badge" alt="State Management">
  <img src="https://img.shields.io/badge/Structure-Modular-orange?style=for-the-badge" alt="Structure">
</div>

<div align="center">
  <h3>🎯 Comprehensive Architecture Documentation</h3>
  <p><em>Understanding the structure, flow, and design principles of AlgoViz</em></p>
</div>

---

## 📁 Project Structure

```
📦 algoviz/
├── 📂 lib/                          # 🎯 Main application source code
│   ├── 🧮 algorithms/               # Algorithm implementations & visualizers
│   │   ├── 🔄 sorting/              # Sorting algorithm visualizers
│   │   │   ├── bubble_sort.dart
│   │   │   ├── merge_sort.dart
│   │   │   ├── quick_sort.dart
│   │   │   └── sorting_visualizer.dart
│   │   ├── 🔍 searching/            # Search algorithm implementations
│   │   │   ├── binary_search.dart
│   │   │   ├── linear_search.dart
│   │   │   └── search_visualizer.dart
│   │   ├── 🌳 data_structures/      # Data structure visualizations
│   │   │   ├── binary_search_tree.dart
│   │   │   ├── linked_list.dart
│   │   │   ├── stack_queue.dart
│   │   │   └── graph_structures.dart
│   │   └── 🛣️ graph/               # Graph algorithms & traversals
│   │       ├── graph_traversal.dart
│   │       ├── dijkstra.dart
│   │       └── minimum_spanning_tree.dart
│   │
│   ├── 📱 pages/                    # Main application screens
│   │   ├── 🏠 dashboard_page.dart   # Home dashboard with algorithm grid
│   │   ├── 🔐 login_page.dart       # User authentication screen
│   │   ├── 👤 profile_page.dart     # User profile & settings
│   │   ├── ℹ️ about_page.dart       # About & help information
│   │   └── 🎯 algorithm_detail_page.dart # Individual algorithm details
│   │
│   ├── 🖼️ screens/                  # Specialized screen components
│   │   ├── 🔐 auth/                 # Authentication related screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── 👤 profile/              # Profile management screens
│   │   │   ├── edit_profile_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── progress_screen.dart
│   │   └── 🎓 learning/             # Learning & tutorial screens
│   │       ├── tutorial_screen.dart
│   │       └── quiz_screen.dart
│   │
│   ├── 🧩 widgets/                  # Reusable UI components
│   │   ├── 🎨 common/               # Common UI elements
│   │   │   ├── animated_background.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   ├── 🧭 navigation/           # Navigation components
│   │   │   ├── navigation_drawer.dart
│   │   │   ├── navigation_rail.dart
│   │   │   └── bottom_navigation.dart
│   │   ├── 🎯 algorithm/            # Algorithm-specific widgets
│   │   │   ├── algorithm_card.dart
│   │   │   ├── visualization_canvas.dart
│   │   │   ├── control_panel.dart
│   │   │   └── step_indicator.dart
│   │   └── 📊 charts/               # Data visualization widgets
│   │       ├── bar_chart.dart
│   │       ├── complexity_chart.dart
│   │       └── performance_graph.dart
│   │
│   ├── 🔄 providers/                # State management (Provider pattern)
│   │   ├── 🎨 theme_provider.dart   # Theme & appearance management
│   │   ├── 👤 user_provider.dart    # User authentication & data
│   │   ├── 🧮 algorithm_provider.dart # Algorithm state management
│   │   ├── 📊 progress_provider.dart # Learning progress tracking
│   │   └── ⚙️ settings_provider.dart # App settings & preferences
│   │
│   ├── 📋 models/                   # Data models & entities
│   │   ├── 👤 user_model.dart       # User data structure
│   │   ├── 🧮 algorithm_model.dart  # Algorithm metadata
│   │   ├── 📊 progress_model.dart   # Progress tracking data
│   │   ├── 🎯 step_model.dart       # Algorithm step representation
│   │   └── ⚙️ settings_model.dart   # App settings structure
│   │
│   ├── 🔧 services/                 # Business logic & external services
│   │   ├── 🔐 auth_service.dart     # Authentication logic
│   │   ├── 💾 storage_service.dart  # Local data persistence
│   │   ├── 🌐 api_service.dart      # External API communication
│   │   ├── 📊 analytics_service.dart # Usage analytics
│   │   └── 🔔 notification_service.dart # Push notifications
│   │
│   ├── 🎨 theme/                    # UI theme & styling
│   │   ├── 🌈 app_theme.dart        # Main theme configuration
│   │   ├── 🎨 colors.dart           # Color palette definitions
│   │   ├── 📝 typography.dart       # Text styles & fonts
│   │   ├── 🖼️ decorations.dart     # UI decorations & borders
│   │   └── 📐 dimensions.dart       # Spacing & sizing constants
│   │
│   ├── 🛠️ utils/                    # Utility functions & helpers
│   │   ├── 🔧 constants.dart        # App-wide constants
│   │   ├── 🎯 extensions.dart       # Dart extensions
│   │   ├── 📱 responsive.dart       # Responsive design helpers
│   │   ├── 🎨 animations.dart       # Animation utilities
│   │   ├── 📊 validators.dart       # Input validation functions
│   │   └── 🔄 converters.dart       # Data conversion utilities
│   │
│   ├── 🧭 routes/                   # Navigation & routing
│   │   ├── 🛣️ app_routes.dart       # Route definitions
│   │   ├── 🧭 route_generator.dart  # Dynamic route generation
│   │   └── 🔒 route_guards.dart     # Authentication guards
│   │
│   └── 🚀 main.dart                 # Application entry point
│
├── 🧪 test/                         # Test files & test utilities
│   ├── 🧩 widget_test.dart          # Widget testing
│   ├── 🔧 unit_test.dart            # Unit testing
│   └── 🔗 integration_test.dart     # Integration testing
│
├── 🖼️ assets/                       # Static assets & resources
│   ├── 🖼️ images/                   # Image assets
│   ├── 🎨 icons/                    # Custom icons
│   ├── 🎵 sounds/                   # Audio files
│   └── 📄 fonts/                    # Custom fonts
│
├── 🌐 web/                          # Web-specific files
├── 🤖 android/                      # Android-specific configuration
├── 🍎 ios/                          # iOS-specific configuration
├── 🪟 windows/                      # Windows-specific configuration
├── 🍎 macos/                        # macOS-specific configuration
├── 🐧 linux/                        # Linux-specific configuration
│
├── 📋 pubspec.yaml                  # Project dependencies & metadata
├── 📖 README.md                     # Project documentation
├── 📄 LICENSE                       # License information
└── 🔧 analysis_options.yaml         # Code analysis configuration
```

## 🏛️ Architecture Principles

<table>
<tr>
<td width="50%">

#### 🎯 **Clean Architecture**
- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Easy to unit test individual components
- **Maintainability**: Clear structure for easy maintenance

</td>
<td width="50%">

#### 🔄 **State Management**
- **Provider Pattern**: Centralized state management
- **Reactive Programming**: UI automatically updates with state changes
- **Immutable State**: Predictable state transitions
- **Scoped Providers**: Efficient state distribution

</td>
</tr>
</table>

## 📊 Module Breakdown

| 📁 **Module** | 🎯 **Purpose** | 🔧 **Key Components** | 📈 **Complexity** |
|---------------|----------------|------------------------|-------------------|
| 🧮 **Algorithms** | Core algorithm implementations | Sorting, Searching, Graph algorithms | ⭐⭐⭐⭐ |
| 📱 **Pages** | Main application screens | Dashboard, Profile, Authentication | ⭐⭐⭐ |
| 🧩 **Widgets** | Reusable UI components | Cards, Charts, Navigation | ⭐⭐ |
| 🔄 **Providers** | State management | Theme, User, Algorithm states | ⭐⭐⭐ |
| 🔧 **Services** | Business logic & APIs | Authentication, Storage, Analytics | ⭐⭐⭐⭐ |
| 🎨 **Theme** | UI styling & theming | Colors, Typography, Animations | ⭐⭐ |
| 🛠️ **Utils** | Helper functions | Constants, Extensions, Validators | ⭐ |

## 🔄 Data Flow Architecture

<div align="center">

```
                    🖱️ USER INTERACTION
                           │
                           ▼
    ┌─────────────────────────────────────────────────────────┐
    │                  📱 UI LAYER                            │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
    │  │   Pages     │ │   Screens   │ │    Widgets      │   │
    │  │ 🏠Dashboard │ │ 🔐Auth      │ │ 🧩Components    │   │
    │  │ 👤Profile   │ │ 🎓Learning  │ │ 🎨Animations    │   │
    │  └─────────────┘ └─────────────┘ └─────────────────┘   │
    └─────────────────────┬───────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────┐
    │                🔄 PROVIDER LAYER                        │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
    │  │Theme        │ │User         │ │Algorithm        │   │
    │  │Provider     │ │Provider     │ │Provider         │   │
    │  │🎨          │ │👤          │ │🧮              │   │
    │  └─────────────┘ └─────────────┘ └─────────────────┘   │
    └─────────────┬───────────────────────┬───────────────────┘
                  │                       │
                  ▼                       ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │    🔧 SERVICE LAYER     │    │  🧮 ALGORITHM ENGINE    │
    │  ┌─────────────────┐   │    │  ┌─────────────────┐   │
    │  │🔐 Auth Service  │   │    │  │🔄 Sorting       │   │
    │  │💾 Storage       │   │    │  │🔍 Searching     │   │
    │  │🌐 API Service   │   │    │  │🌳 Data Struct   │   │
    │  │📊 Analytics     │   │    │  │🛣️ Graph Algo    │   │
    │  └─────────────────┘   │    │  └─────────────────┘   │
    └─────────┬───────────────┘    └─────────┬───────────────┘
              │                              │
              ▼                              ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │    📋 MODEL LAYER       │    │  🎨 VISUALIZATION       │
    │  ┌─────────────────┐   │    │  ┌─────────────────┐   │
    │  │👤 User Model    │   │    │  │📊 Charts        │   │
    │  │🧮 Algorithm     │   │    │  │🎯 Canvas        │   │
    │  │📊 Progress      │   │    │  │⚡ Animations    │   │
    │  │⚙️ Settings      │   │    │  │🎮 Controls      │   │
    │  └─────────────────┘   │    │  └─────────────────┘   │
    └─────────┬───────────────┘    └─────────┬───────────────┘
              │                              │
              ▼                              │
    ┌─────────────────────────┐              │
    │    💾 DATA STORAGE      │              │
    │  ┌─────────────────┐   │              │
    │  │🔒 Secure Store  │   │              │
    │  │📱 Preferences   │   │              │
    │  │💿 Local DB      │   │              │
    │  │☁️ Cloud Sync    │   │              │
    │  └─────────────────┘   │              │
    └─────────────────────────┘              │
                                             │
              ┌──────────────────────────────┘
              │
              ▼
    ┌─────────────────────────────────────────────────────────┐
    │                📱 UI LAYER (Updated)                    │
    │           Real-time Visual Feedback                     │
    └─────────────────────────────────────────────────────────┘
```

</div>

## 🎯 Flow Explanation

<table>
<tr>
<td width="33%">

#### 📥 **Input Flow**
```
🖱️ User Action
    ↓
📱 UI Layer
    ↓
🔄 Provider Layer
    ↓
🔧 Service Layer
    ↓
📋 Model Layer
    ↓
💾 Data Storage
```

</td>
<td width="33%">

#### ⚡ **Processing Flow**
```
🔄 Provider Layer
    ↓
🧮 Algorithm Engine
    ↓
🎨 Visualization
    ↓
📊 Real-time Updates
    ↓
📱 UI Refresh
```

</td>
<td width="33%">

#### 🔄 **State Flow**
```
📱 UI Events
    ↓
🔄 State Changes
    ↓
🔔 Notifications
    ↓
🎨 UI Rebuilds
    ↓
✨ Smooth UX
```

</td>
</tr>
</table>

## 🏗️ Architecture Benefits

| 🎯 **Benefit** | 📝 **Description** | 🚀 **Impact** |
|----------------|-------------------|---------------|
| **🔄 Reactive** | UI automatically updates with state changes | Smooth user experience |
| **🧩 Modular** | Clear separation between layers | Easy maintenance & testing |
| **📈 Scalable** | Easy to add new features and algorithms | Future-proof architecture |
| **🎨 Flexible** | Theme and UI can change independently | Customizable experience |
| **⚡ Performant** | Efficient state management and rendering | Fast and responsive |
| **🧪 Testable** | Each layer can be tested independently | High code quality |

## 🔧 Implementation Details

### 🎨 UI Layer Components

#### 📱 Pages
- **Dashboard Page**: Main entry point with algorithm grid layout
- **Login Page**: Authentication interface with social login options
- **Profile Page**: User management and settings interface
- **About Page**: Information and help documentation
- **Algorithm Detail Page**: Individual algorithm visualization and controls

#### 🖼️ Screens
- **Authentication Screens**: Login, register, and password recovery
- **Profile Screens**: Edit profile, settings, and progress tracking
- **Learning Screens**: Tutorials, quizzes, and educational content

#### 🧩 Widgets
- **Common Widgets**: Reusable UI components across the app
- **Navigation Widgets**: Drawer, rail, and bottom navigation
- **Algorithm Widgets**: Specialized components for algorithm visualization
- **Chart Widgets**: Data visualization and performance graphs

### 🔄 State Management Layer

#### Provider Pattern Implementation
- **Theme Provider**: Manages light/dark theme switching and persistence
- **User Provider**: Handles authentication state and user data
- **Algorithm Provider**: Controls algorithm execution and visualization state
- **Progress Provider**: Tracks learning progress and achievements
- **Settings Provider**: Manages app preferences and configuration

### 🔧 Service Layer Architecture

#### Core Services
- **Authentication Service**: Secure login/logout and session management
- **Storage Service**: Local data persistence and caching
- **API Service**: External service communication and data synchronization
- **Analytics Service**: Usage tracking and performance monitoring
- **Notification Service**: Push notifications and alerts

### 📋 Data Models

#### Model Structure
- **User Model**: User profile, preferences, and authentication data
- **Algorithm Model**: Algorithm metadata, complexity, and implementation details
- **Progress Model**: Learning progress, achievements, and statistics
- **Step Model**: Individual algorithm step representation for visualization
- **Settings Model**: App configuration and user preferences

---

<div align="center">
  <p><strong>📚 For more information, see the main <a href="README.md">README.md</a></strong></p>
  <p><em>This architecture ensures scalability, maintainability, and excellent user experience</em></p>
</div>
