import 'package:flutter/material.dart';
import '../services/deezer_service.dart';
import '../models/musique.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  final DeezerService deezerService = DeezerService();

  Future<List<dynamic>> _loadTracks() async {
    return await deezerService.fetchDeezerTracks("rap");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accueil")),
      body: FutureBuilder<List<dynamic>>(
        future: _loadTracks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final tracks = snapshot.data ?? [];

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final title = track['title']?.toString() ?? 'Titre inconnu';
              final artist = track['artist']?['name']?.toString() ?? 'Artiste inconnu';
              final image = track['album']?['cover_medium']?.toString() ?? '';
              final preview = track['preview']?.toString() ?? '';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: image.isNotEmpty
                      ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.music_note),
                  title: Text(title),
                  subtitle: Text(artist),
                  trailing: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      if (preview.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Pas d'extrait disponible")),
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        '/player',
                        arguments: Musique(
                          id: track['id'].toString(),
                          titre: title,
                          artiste: artist,
                          audioUrl: preview,
                          imageUrl: image,
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
