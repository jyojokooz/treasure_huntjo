Directory structure:
└── jyojokooz-treasure_huntjo/
    └── treasure_hunt_app/
        ├── README.md
        ├── analysis_options.yaml
        ├── firebase.json
        ├── pubspec.lock
        ├── pubspec.yaml
        ├── .firebaserc
        ├── .gitignore
        ├── .metadata
        ├── android/
        │   ├── build.gradle.kts
        │   ├── gradle.properties
        │   ├── settings.gradle.kts
        │   ├── .gitignore
        │   ├── app/
        │   │   ├── build.gradle.kts
        │   │   ├── google-services.json
        │   │   └── src/
        │   │       ├── debug/
        │   │       │   └── AndroidManifest.xml
        │   │       ├── main/
        │   │       │   ├── AndroidManifest.xml
        │   │       │   ├── kotlin/
        │   │       │   │   └── com/
        │   │       │   │       └── example/
        │   │       │   │           └── treasure_hunt_app/
        │   │       │   │               └── MainActivity.kt
        │   │       │   └── res/
        │   │       │       ├── drawable/
        │   │       │       │   └── launch_background.xml
        │   │       │       ├── drawable-v21/
        │   │       │       │   └── launch_background.xml
        │   │       │       ├── mipmap-hdpi/
        │   │       │       ├── mipmap-mdpi/
        │   │       │       ├── mipmap-xhdpi/
        │   │       │       ├── mipmap-xxhdpi/
        │   │       │       ├── mipmap-xxxhdpi/
        │   │       │       ├── values/
        │   │       │       │   └── styles.xml
        │   │       │       └── values-night/
        │   │       │           └── styles.xml
        │   │       └── profile/
        │   │           └── AndroidManifest.xml
        │   └── gradle/
        │       └── wrapper/
        │           └── gradle-wrapper.properties
        ├── assets/
        │   ├── audio/
        │   └── images/
        ├── ios/
        │   ├── .gitignore
        │   ├── Flutter/
        │   │   ├── AppFrameworkInfo.plist
        │   │   ├── Debug.xcconfig
        │   │   └── Release.xcconfig
        │   ├── Runner/
        │   │   ├── AppDelegate.swift
        │   │   ├── Info.plist
        │   │   ├── Runner-Bridging-Header.h
        │   │   ├── Assets.xcassets/
        │   │   │   ├── AppIcon.appiconset/
        │   │   │   │   └── Contents.json
        │   │   │   └── LaunchImage.imageset/
        │   │   │       ├── README.md
        │   │   │       └── Contents.json
        │   │   └── Base.lproj/
        │   │       ├── LaunchScreen.storyboard
        │   │       └── Main.storyboard
        │   ├── Runner.xcodeproj/
        │   │   ├── project.pbxproj
        │   │   ├── project.xcworkspace/
        │   │   │   ├── contents.xcworkspacedata
        │   │   │   └── xcshareddata/
        │   │   │       ├── IDEWorkspaceChecks.plist
        │   │   │       └── WorkspaceSettings.xcsettings
        │   │   └── xcshareddata/
        │   │       └── xcschemes/
        │   │           └── Runner.xcscheme
        │   ├── Runner.xcworkspace/
        │   │   ├── contents.xcworkspacedata
        │   │   └── xcshareddata/
        │   │       ├── IDEWorkspaceChecks.plist
        │   │       └── WorkspaceSettings.xcsettings
        │   └── RunnerTests/
        │       └── RunnerTests.swift
        ├── lib/
        │   ├── firebase_options.dart
        │   ├── main.dart
        │   ├── models/
        │   │   ├── level3_clue_model.dart
        │   │   ├── puzzle_model.dart
        │   │   ├── quiz_model.dart
        │   │   ├── team_model.dart
        │   │   └── assets/
        │   │       └── images/
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
        │   │   │   ├── admin_profile_view.dart
        │   │   │   ├── approved_teams_view.dart
        │   │   │   ├── manage_level1_quiz_view.dart
        │   │   │   ├── manage_level2_puzzles_view.dart
        │   │   │   ├── manage_level3_clues_view.dart
        │   │   │   ├── manage_levels_view.dart
        │   │   │   ├── manage_quizzes_view.dart
        │   │   │   ├── manage_teams_view.dart
        │   │   │   └── pending_teams_view.dart
        │   │   └── game_panel/
        │   │       ├── clues_view.dart
        │   │       ├── leaderboard_hub_view.dart
        │   │       ├── leaderboard_view.dart
        │   │       ├── level1_leaderboard_view.dart
        │   │       ├── level2_leaderboard_view.dart
        │   │       ├── level2_puzzle_screen.dart
        │   │       ├── level3_leaderboard_view.dart
        │   │       ├── level3_screen.dart
        │   │       ├── level_leaderboard_view.dart
        │   │       ├── qr_scanner_screen.dart
        │   │       ├── quiz_screen.dart
        │   │       └── team_view.dart
        │   ├── services/
        │   │   ├── auth_service.dart
        │   │   ├── firestore_service.dart
        │   │   ├── image_upload_service.dart
        │   │   └── music_service.dart
        │   └── widgets/
        │       ├── custom_admin_nav_bar.dart
        │       ├── game_nav_bar.dart
        │       └── glassmorphic_container.dart
        ├── linux/
        │   ├── CMakeLists.txt
        │   ├── .gitignore
        │   ├── flutter/
        │   │   ├── CMakeLists.txt
        │   │   ├── generated_plugin_registrant.cc
        │   │   ├── generated_plugin_registrant.h
        │   │   └── generated_plugins.cmake
        │   └── runner/
        │       ├── CMakeLists.txt
        │       ├── main.cc
        │       ├── my_application.cc
        │       └── my_application.h
        ├── macos/
        │   ├── .gitignore
        │   ├── Flutter/
        │   │   ├── Flutter-Debug.xcconfig
        │   │   ├── Flutter-Release.xcconfig
        │   │   └── GeneratedPluginRegistrant.swift
        │   ├── Runner/
        │   │   ├── AppDelegate.swift
        │   │   ├── DebugProfile.entitlements
        │   │   ├── Info.plist
        │   │   ├── MainFlutterWindow.swift
        │   │   ├── Release.entitlements
        │   │   ├── Assets.xcassets/
        │   │   │   └── AppIcon.appiconset/
        │   │   │       └── Contents.json
        │   │   ├── Base.lproj/
        │   │   │   └── MainMenu.xib
        │   │   └── Configs/
        │   │       ├── AppInfo.xcconfig
        │   │       ├── Debug.xcconfig
        │   │       ├── Release.xcconfig
        │   │       └── Warnings.xcconfig
        │   ├── Runner.xcodeproj/
        │   │   ├── project.pbxproj
        │   │   ├── project.xcworkspace/
        │   │   │   └── xcshareddata/
        │   │   │       └── IDEWorkspaceChecks.plist
        │   │   └── xcshareddata/
        │   │       └── xcschemes/
        │   │           └── Runner.xcscheme
        │   ├── Runner.xcworkspace/
        │   │   ├── contents.xcworkspacedata
        │   │   └── xcshareddata/
        │   │       └── IDEWorkspaceChecks.plist
        │   └── RunnerTests/
        │       └── RunnerTests.swift
        ├── test/
        │   └── widget_test.dart
        ├── web/
        │   ├── index.html
        │   ├── manifest.json
        │   └── icons/
        ├── windows/
        │   ├── CMakeLists.txt
        │   ├── .gitignore
        │   ├── flutter/
        │   │   ├── CMakeLists.txt
        │   │   ├── generated_plugin_registrant.cc
        │   │   ├── generated_plugin_registrant.h
        │   │   └── generated_plugins.cmake
        │   └── runner/
        │       ├── CMakeLists.txt
        │       ├── flutter_window.cpp
        │       ├── flutter_window.h
        │       ├── main.cpp
        │       ├── resource.h
        │       ├── runner.exe.manifest
        │       ├── Runner.rc
        │       ├── utils.cpp
        │       ├── utils.h
        │       ├── win32_window.cpp
        │       ├── win32_window.h
        │       └── resources/
        └── .firebase/
            └── hosting.YnVpbGRcd2Vi.cache
