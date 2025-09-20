import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // **NEW: Import for kIsWeb**
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasure_hunt_app/firebase_options.dart';
import 'package:treasure_hunt_app/screens/splash_screen.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/music_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // **THE FIX: Use kIsWeb to run code only on mobile platforms**
    // 'kIsWeb' is a special constant that is true only when the app is running in a web browser.
    // The '!' makes the condition "if not web".
    if (!kIsWeb) {
      // If we are on Android, iOS, or desktop, play the music automatically.
      MusicService.instance.playBackgroundMusic();
    }
    // If we are on the web, this code is skipped, and the music will wait for user interaction.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MusicService.instance.resumeBackgroundMusic();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      MusicService.instance.pauseBackgroundMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Treasure Hunt',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          brightness: Brightness.dark,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
