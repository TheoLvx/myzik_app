import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/musique.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Musique>> _getFavoriteMusics() async {
    if (userId == null) return [];

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(userId)
          .get();

      final data = userDoc.data() as Map<String, dynamic>?;

      List<String> favorisIds = [];
      if (data != null && data['favoris'] != null) {
        favorisIds = List<String>.from(data['favoris']);
      }

      if (favorisIds.isEmpty) return [];

      final musiquesSnapshot = await FirebaseFirestore.instance
          .collection('musiques')
          .where(FieldPath.documentId, whereIn: favorisIds)
          .get();

      return musiquesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Musique(
          id: doc.id,
          titre: data['titre'],
          artiste: data['artiste'],
          audioUrl: data['audioUrl'],
          imageUrl: data['imageUrl'],
        );
      }).toList();
    } catch (e) {
      print('❌ Erreur chargement favoris : $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes favoris')),
      body: FutureBuilder<List<Musique>>(
        future: _getFavoriteMusics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune musique en favori.'));
          }

          final musiques = snapshot.data!;

          return ListView.builder(
            itemCount: musiques.length,
            itemBuilder: (context, index) {
              final musique = musiques[index];
              return ListTile(
                leading: musique.imageUrl != null
                    ? Image.network(musique.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.music_note),
                title: Text(musique.titre),
                subtitle: Text(musique.artiste),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(musique: musique),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
