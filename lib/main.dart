// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'firebase_options.dart';
import 'models/musique.dart'; // Importer le modèle Musique

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
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        // Met à jour la route pour passer le paramètre 'musique'
        '/player': (context) {
          final Musique musique = ModalRoute.of(context)!.settings.arguments as Musique;
          return PlayerScreen(musique: musique); // Passe l'objet musique au PlayerScreen
        },
        '/favorites': (_) => FavoritesScreen(),
        '/settings': (_) => SettingsScreen(),
      },
    );
  }
}
