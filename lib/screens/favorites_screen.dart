import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/musique.dart';

class FavoritesScreen extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Musique>> _getFavoriteMusics() async {
    if (userId == null) return [];

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('utilisateurs')
        .doc(userId)
        .get();

    List<String> favorisIds = [];
    if (userDoc.exists && userDoc['favoris'] != null) {
      favorisIds = List<String>.from(userDoc['favoris']);
    }

    print("Favoris récupérés : $favorisIds");

    if (favorisIds.isEmpty) return [];

    QuerySnapshot musiquesSnapshot = await FirebaseFirestore.instance
        .collection('musiques')
        .where(FieldPath.documentId, whereIn: favorisIds)
        .get();

    print("Musiques trouvées : ${musiquesSnapshot.docs.length}");

    return musiquesSnapshot.docs.map((doc) {
      return Musique(
        id: doc.id,
        titre: doc['titre'],
        artiste: doc['artiste'],
        audioUrl: doc['audioUrl'],
        imageUrl: doc['imageUrl'],
      );
    }).toList();
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
            return Center(child: Text('Aucune musique en favori'));
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
                  // Navigue vers l'écran du player si tu veux
                },
              );
            },
          );
        },
      ),
    );
  }
}
