import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Utilisateur'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Text(
                (user?.displayName ?? '?')[0].toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              backgroundColor: Colors.deepPurple,
            ),
          ),
          ListTile(
            title: Text('Accueil'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            title: Text('Favoris'),
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            title: Text('Paramètres'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          if (user != null)
            ListTile(
              title: Text('Déconnexion'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
    );
  }
}
