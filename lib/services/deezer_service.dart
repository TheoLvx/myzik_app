import 'dart:convert';
import 'package:http/http.dart' as http;

class DeezerService {
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
}
