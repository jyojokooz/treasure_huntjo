import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// **FIX: Re-added the missing import for material.dart**
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
    // This line will now work correctly
    WidgetsBinding.instance.addObserver(this);

    // We don't play music here to support web autoplay policies
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
    // This line will now work correctly
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
