import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ajouter une musique aux favoris
  Future<void> addToFavorites(String musiqueId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('utilisateurs').doc(user.uid).update({
        'favoris': FieldValue.arrayUnion([musiqueId])
      });
      print('✅ Musique ajoutée aux favoris');
    } catch (e) {
      print('❌ Erreur ajout aux favoris : $e');
    }
  }

  // Retirer une musique des favoris
  Future<void> removeFromFavorites(String musiqueId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('utilisateurs').doc(user.uid).update({
        'favoris': FieldValue.arrayRemove([musiqueId])
      });
      print('🗑️ Musique retirée des favoris');
    } catch (e) {
      print('❌ Erreur retrait favoris : $e');
    }
  }

  // Vérifier si une musique est déjà dans les favoris
  Future<bool> isFavorite(String musiqueId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
      final data = doc.data() as Map<String, dynamic>?;

      final List<dynamic> favoris = data?['favoris'] ?? [];
      return favoris.contains(musiqueId);
    } catch (e) {
      print('❌ Erreur vérification favoris : $e');
      return false;
    }
  }
}
