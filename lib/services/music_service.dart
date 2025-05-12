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

  // Ajouter une musique en favori
  Future<void> addToFavorites(String musicId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db
          .collection('utilisateurs')
          .doc(uid)
          .collection('favoris')
          .doc(musicId)
          .set({'addedAt': Timestamp.now()});
    }
  }

  // Supprimer une musique des favoris
  Future<void> removeFromFavorites(String musicId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db
          .collection('utilisateurs')
          .doc(uid)
          .collection('favoris')
          .doc(musicId)
          .delete();
    }
  }

  // Récupérer les favoris
  Stream<QuerySnapshot> getFavorites() {
    final uid = _auth.currentUser?.uid;
    return _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('favoris')
        .snapshots();
  }

  // Appel API Deezer (exemple pour chercher du rap)
  Future<List<dynamic>> fetchDeezerTracks(String query) async {
    final response = await http.get(Uri.parse('https://api.deezer.com/search?q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Erreur API Deezer');
    }
  }
}
