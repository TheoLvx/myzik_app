import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart' as player_screen;
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'models/musique.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyZikApp());
}

class MyZikApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyZik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/favorites': (_) => FavoritesScreen(),
        '/settings': (_) => SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/player') {
          final musique = settings.arguments as Musique;
          return MaterialPageRoute(
            builder: (_) => player_screen.PlayerScreen(musique: musique),
          );
        }
        return null;
      },
    );
  }
}
