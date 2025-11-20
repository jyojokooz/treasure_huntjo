
# 📱 Treasure Hunt App

**Flutter + Firebase** — *A modern, interactive treasure hunt application designed for college events, competitions, and fun group games.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows%20%7C%20iOS-lightgrey?style=for-the-badge)]()

---

## 🚀 Overview

This repository contains a cross-platform Flutter application built with Firebase backend services. The app is tailored for campus treasure hunts and similar interactive challenges where multiple teams compete through progressive levels (quiz, logic puzzles, QR-based clue hunts) with live leaderboards and admin management tools.

---

## ✨ Features

- 🔐 **Authentication** — Email/password authentication via Firebase Auth.
- 👥 **Team Management** — Team registration with admin approval flow.
- 🧩 **Multi-level Gameplay**
  - **Level 1:** Quiz (time-limited / score-based).
  - **Level 2:** Logic puzzles.
  - **Level 3:** Treasure hunt with clues and QR code scanning.
- 📊 **Live Leaderboard** — Real-time scoring using Firestore listeners.
- 🛠️ **Admin Panel** — Manage teams, approve participants, verify winners, edit content.
- 🎵 **Audio** — Background music and SFX support.
- 🌐 **Cross-platform** — Android, iOS, Web, Windows, macOS, Linux.

---

## 🗂 Project Structure

```
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
    ├── ios/
    │   └── Runner/GoogleService-Info.plist
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
```

---

## 🛠 Installation & Local Setup

> **Prerequisites**
> - Flutter SDK (stable channel) — https://flutter.dev
> - Dart (bundled with Flutter)
> - Firebase CLI (optional but recommended) — https://firebase.google.com/docs/cli
> - Platform-specific tooling (Android Studio/SDK for Android, Xcode for iOS)

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/jyojokooz-treasure_huntjo.git
cd jyojokooz-treasure_huntjo/treasure_hunt_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
You must set up your own Firebase project and add platform-specific configuration files.

#### Android
- In Firebase Console, add an Android app using your app's package name.
- Download `google-services.json` and place it in `android/app/`.

#### iOS
- Add an iOS app in Firebase Console.
- Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

#### Web
- Option 1 (recommended): Run `flutterfire configure` from the project root to generate `lib/firebase_options.dart`.
- Option 2: Manually add Firebase SDK config to `web/index.html` and create `lib/firebase_options.dart` yourself.

#### Firestore rules & indexes
For development you can start in test mode, but **do not** leave production apps in test mode. Configure security rules and indexes according to your app needs.

### 4. Run the app

- Run on Chrome (web):
```bash
flutter run -d chrome
```

- Run on Android:
```bash
flutter run -d android
```

- Build release for Android:
```bash
flutter build apk --release
```

---

## 🔧 Firebase Features to Enable

1. **Authentication**: Enable Email/Password provider.
2. **Cloud Firestore**: Create required collections (teams, games, puzzles, quizzes, leaderboard).
3. **Firebase Storage**: For uploading team avatars and media assets.
4. **Cloud Functions (optional)**: For server-side verification, score processing, or scheduled tasks.
5. **Hosting (optional)**: For deploying web builds.

---

## ⚙️ Example Firestore Structure (suggested)

```
/games/{gameId}
/games/{gameId}/levels/{levelId}
/teams/{teamId}
/teams/{teamId}/members/{memberId}
/leaderboard/{gameId}/scores/{teamId}
```

Design your document model to minimize hot documents and optimize queries with proper indexing.

---

## 🧾 Admin Panel Notes

- Admins should be able to:
  - Approve or reject team registrations.
  - Edit quiz and puzzle content.
  - Trigger manual verification for winners.
  - View and export leaderboard data (CSV/JSON).
- Protect admin routes with role-based checks in Firestore or via Firebase Custom Claims.

---

## 🎵 Audio & Assets

- Keep audio files short and optimized (Ogg/MP3).
- Load large assets from Firebase Storage or serve them via CDN to reduce app bundle size.
- Respect asset licensing for any music or artwork used.

---

## 🤝 Contributing

Thanks for your interest! Please follow these steps:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/AmazingFeature`.
3. Commit your changes: `git commit -m "Add some AmazingFeature"`.
4. Push to your branch: `git push origin feature/AmazingFeature`.
5. Open a Pull Request describing the change.

Please make sure you run `flutter analyze` and include tests where applicable.

---

## 📜 License

This project is distributed under the **MIT License**. See the `LICENSE` file for details.

---

## 💬 Contact

Created with ❤️ by **Joel S Raphael**  
Email: `joelraphael6425@gmail.com` (replace with a public contact if desired)

---

*© 2025 All rights reserved.*
