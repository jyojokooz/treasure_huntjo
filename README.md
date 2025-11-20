<div align="center">
  <h1>📱 Treasure Hunt App</h1>
  <h3>Flutter + Firebase</h3>
  <p>
    <strong>A modern, interactive treasure hunt application designed for college events, competitions, and fun interactive games.</strong>
  </p>

  <!-- BADGES -->
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Platform-Android%20|%20Web%20|%20Windows%20|%20iOS-lightgrey?style=for-the-badge" alt="Platform" />
  </p>
</div>

<hr>

## 🚀 Features

This app is designed to handle multiple teams competing in real-time through various levels of difficulty.

*   🔐 **Authentication:** Secure Email/Password login via Firebase Auth.
*   👥 **Team Management:** Registration with Admin approval system.
*   🧩 **Level-Based Gameplay:**
    *   **Level 1:** Quiz (Time-based/Score-based).
    *   **Level 2:** Logic Puzzles.
    *   **Level 3:** Treasure Hunt (Clues + QR Code Scanning).
*   📊 **Live Leaderboard:** Dynamic real-time score updates.
*   🛠️ **Admin Panel:** Full control to manage teams, verify winners, and edit quizzes/puzzles.
*   🎵 **Immersive Audio:** Background music and sound effects.
*   🌐 **Cross-Platform:** Optimized for Android, Web, Windows, macOS, and Linux.

---

## 🗂️ Directory Structure

<details>
  <summary><strong>📁 Click to expand full project tree</strong></summary>
  <pre>
jyojokooz-treasure_huntjo/
└── treasure_hunt_app/
    ├── README.md
    ├── analysis_options.yaml
    ├── firebase.json
    ├── pubspec.yaml
    ├── android/
    │   ├── app/
    │   │   ├── google-services.json
    │   │   └── src/main/AndroidManifest.xml
    ├── assets/
    │   ├── audio/
    │   └── images/
    ├── lib/
    │   ├── firebase_options.dart
    │   ├── main.dart
    │   ├── models/
    │   │   ├── level3_clue_model.dart
    │   │   ├── puzzle_model.dart
    │   │   ├── quiz_model.dart
    │   │   └── team_model.dart
    │   ├── screens/
    │   │   ├── admin_dashboard.dart
    │   │   ├── auth_wrapper.dart
    │   │   ├── decision_screen.dart
    │   │   ├── gamer_dashboard.dart
    │   │   ├── login_screen.dart
    │   │   ├── pending_screen.dart
    │   │   ├── register_screen.dart
    │   │   ├── splash_screen.dart
    │   │   ├── winner_announcement_screen.dart
    │   │   ├── admin_panel/
    │   │   └── game_panel/
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   ├── firestore_service.dart
    │   │   ├── image_upload_service.dart
    │   │   └── music_service.dart
    │   └── widgets/
    │       ├── custom_admin_nav_bar.dart
    │       ├── game_nav_bar.dart
    │       └── glassmorphic_container.dart
    ├── web/
    │   ├── index.html
    │   └── manifest.json
    └── .firebase/
  </pre>
</details>

### 📦 Simplified Folder Explanation

| Folder | Purpose |
| :--- | :--- |
| `lib/` | Main Flutter source code containing logic and UI. |
| `screens/` | UI Pages (Admin panel, Game panel, Login, etc.). |
| `services/` | Backend logic (Firebase Auth, Firestore, Storage, Audio). |
| `models/` | Data models for quizzes, puzzles, and team structures. |
| `assets/` | Static files like images, logos, and audio files. |
| `widgets/` | Reusable UI components (Nav bars, Glassmorphism cards). |

---

## 🛠️ Installation Guide

Follow these steps to run the project locally.

### 1️⃣ Clone the Project

git clone https://github.com/yourusername/jyojokooz-treasure_huntjo.git
cd treasure_hunt_app
---
##$ 2️⃣ Install Dependencies

flutter pub get

3️⃣ Run the App
code
Bash
# To run on Chrome (Web)
flutter run -d chrome

# To run on Android
flutter run -d android


🔥 Firebase Setup
To make the app functional, you need to link your own Firebase project.

1.Create a Project: Go to Firebase Console and create a new project.
2.Add Apps: Add Android, iOS, and Web apps within the Firebase project.
3.Download Config Files:
  Android: Download google-services.json and place it in android/app/.
  iOS: Download GoogleService-Info.plist and place it in ios/Runner/.
  Web/All: Run flutterfire configure to generate lib/firebase_options.dart.
4.Enable Services:
  Authentication: Enable Email/Password provider.
  Firestore Database: Create a database (Start in Test Mode).
  Storage: Enable storage for image uploads.

🌐 Deploy to Web (Firebase Hosting)
Build the web version:

flutter build web --release


Initialize and Deploy:

firebase login
firebase init
# Select 'Hosting' > Select 'Use existing project' > Select 'build/web' as public directory
firebase deploy

🤝 Contributing
Contributions, issues, and feature requests are welcome!

1.Fork the Project
2.Create your Feature Branch (git checkout -b feature/AmazingFeature)
3.Commit your Changes (git commit -m 'Add some AmazingFeature')
4.Push to the Branch (git push origin feature/AmazingFeature)
5.Open a Pull Request

📜 License
Distributed under the MIT License. See LICENSE for more information.
<div align="center">
<p>Created with ❤️ by <strong>Joel S Raphael</strong></p>
<p>© 2025 All Rights Reserved</p>
</div>
```
