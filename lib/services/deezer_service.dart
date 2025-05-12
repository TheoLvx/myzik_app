import 'dart:convert';
import 'package:http/http.dart' as http;

class DeezerService {
  // Recherche par mot-clé
  Future<List<dynamic>> fetchDeezerTracks(String query) async {
    final url = Uri.parse(
      'https://thingproxy.freeboard.io/fetch/https://api.deezer.com/search?q=$query',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Erreur proxy Deezer (code ${response.statusCode})');
    }
  }

  // Récupère les musiques populaires par genre Deezer (ex: 132 = Pop, 152 = Electro)
  Future<List<dynamic>> fetchTracksByGenre(String genreId) async {
    final url = Uri.parse(
      'https://thingproxy.freeboard.io/fetch/https://api.deezer.com/editorial/$genreId/charts',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks']['data'];
    } else {
      throw Exception('Erreur chargement genre (code ${response.statusCode})');
    }
  }
}
