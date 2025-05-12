import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> ajouterFausseDonnees() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('musiques').doc('xyz456').set({
      'titre': 'Shape of You',
      'artiste': 'Ed Sheeran',
      'lienAudio': 'https://www.example.com/audio/shapeofyou.mp3',
      'image': 'https://www.example.com/images/shapeofyou.jpg',
    });

    await firestore.collection('musiques').doc('abc789').set({
      'titre': 'Blinding Lights',
      'artiste': 'The Weeknd',
      'lienAudio': 'https://www.example.com/audio/blindinglights.mp3',
      'image': 'https://www.example.com/images/blindinglights.jpg',
    });

    await firestore.collection('ecoutes').add({
      'userId': 'abc123',
      'musiqueId': 'xyz456',
      'geolocalisation': {
        'latitude': 48.8566,
        'longitude': 2.3522,
      },
      'timestamp': Timestamp.now(),
    });

    await firestore.collection('ecoutes').add({
      'userId': 'def456',
      'musiqueId': 'abc789',
      'geolocalisation': {
        'latitude': 40.7128,
        'longitude': -74.0060,
      },
      'timestamp': Timestamp.now(),
    });

    print('Fausse données ajoutées !');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Paramètres de l\'application'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ajouterFausseDonnees();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Données ajoutées à Firestore')),
                );
              },
              child: Text('Ajouter fausses données'),
            ),
          ],
        ),
      ),
    );
  }
}
