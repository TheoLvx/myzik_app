import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class MusicService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer la collection musiques en temps réel
  Stream<QuerySnapshot> getMusicStream() {
    return _db.collection('musiques').snapshots();
  }

  // Ajouter une musique en favori (en supposant que la musique existe déjà dans Firestore)
  Future<void> addToFavorites(String musicId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db
          .collection('utilisateurs')
          .doc(uid)
          .update({
        'favoris': FieldValue.arrayUnion([musicId])
      });
    }
  }

  // Supprimer une musique des favoris
  Future<void> removeFromFavorites(String musicId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db
          .collection('utilisateurs')
          .doc(uid)
          .update({
        'favoris': FieldValue.arrayRemove([musicId])
      });
    }
  }

  // Récupérer les favoris
  Stream<QuerySnapshot> getFavoritesStream() {
    final uid = _auth.currentUser?.uid;
    return _db
        .collection('utilisateurs')
        .doc(uid)
        .snapshots();
  }

  // Appel API Deezer pour chercher des morceaux
  Future<List<dynamic>> fetchDeezerTracks(String query) async {
    final url = Uri.parse('https://api.deezer.com/search?q=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // liste des musiques
      } else {
        throw Exception('Erreur API Deezer');
      }
    } catch (e) {
      print("Erreur appel API Deezer : $e");
      return [];
    }
  }

  // Sauvegarder une musique Deezer dans Firestore (pour qu'elle soit lisible dans l'app)
  Future<void> saveTrackToFirestore(Map<String, dynamic> track) async {
    final String trackId = track['id'].toString();

    final docRef = _db.collection('musiques').doc(trackId);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'titre': track['title'],
        'artiste': track['artist']['name'],
        'audioUrl': track['preview'],
        'imageUrl': track['album']['cover_medium'],
      });

      print("✅ Musique $trackId enregistrée dans Firestore");
    } else {
      print("ℹ️ Musique $trackId existe déjà");
    }
  }
}
