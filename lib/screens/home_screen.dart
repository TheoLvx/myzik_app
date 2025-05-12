import 'package:flutter/material.dart';
import '../services/deezer_service.dart';
import '../models/musique.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeezerService deezerService = DeezerService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'Tous';
  late Future<List<dynamic>> _tracksFuture;

  final List<String> genres = ['Tous', 'Rap', 'Pop', 'Rock', 'Jazz', 'Classique'];

  @override
  void initState() {
    super.initState();
    _tracksFuture = deezerService.fetchDeezerTracks("top"); // suggestion par défaut
  }

  Future<List<dynamic>> _loadTracks({String? query}) async {
    final genre = _selectedGenre == 'Tous' ? '' : _selectedGenre;
    final search = query ?? _searchController.text;
    final fullQuery = [genre, search].where((e) => e.isNotEmpty).join(" ");
    return await deezerService.fetchDeezerTracks(fullQuery.isEmpty ? "top" : fullQuery);
  }

  void _performSearch() {
    setState(() {
      _tracksFuture = _loadTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accueil")),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une musique ou un artiste',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedGenre,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGenre = value;
                        _performSearch();
                      });
                    }
                  },
                  items: genres.map((genre) {
                    return DropdownMenuItem(
                      value: genre,
                      child: Text(genre),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _tracksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                }

                final tracks = snapshot.data ?? [];

                if (tracks.isEmpty) {
                  return Center(child: Text("Aucune musique trouvée"));
                }

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
                        onTap: () {
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
                        leading: image.isNotEmpty
                            ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.music_note),
                        title: Text(title),
                        subtitle: Text(artist),
                        trailing: Icon(Icons.play_arrow),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
