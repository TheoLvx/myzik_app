import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../models/musique.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil')),
      drawer: CustomDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('musiques').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final musiques = snapshot.data!.docs;

          if (musiques.isEmpty) {
            return Center(child: Text('Aucune musique disponible.'));
          }

          return ListView.builder(
            itemCount: musiques.length,
            itemBuilder: (context, index) {
              final data = musiques[index].data() as Map<String, dynamic>;
              final musique = Musique.fromMap(data, musiques[index].id);

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    musique.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(musique.titre),
                  subtitle: Text(musique.artiste),
                  trailing: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(musique: musique),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
