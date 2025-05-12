import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fonction pour ajouter une musique aux favoris
  Future<void> addToFavorites(String musiqueId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Ajoute l'ID de la musique à la liste des favoris
        await _firestore
            .collection('utilisateurs')
            .doc(user.uid)
            .update({
          'favoris': FieldValue.arrayUnion([musiqueId]),
        });
        print('Musique ajoutée aux favoris');
      } catch (e) {
        print('Erreur ajout aux favoris: $e');
      }
    } else {
      print('Utilisateur non connecté');
    }
  }

  // Fonction pour retirer une musique des favoris
  Future<void> removeFromFavorites(String musiqueId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Retire l'ID de la musique de la liste des favoris
        await _firestore
            .collection('utilisateurs')
            .doc(user.uid)
            .update({
          'favoris': FieldValue.arrayRemove([musiqueId]),
        });
        print('Musique retirée des favoris');
      } catch (e) {
        print('Erreur retrait des favoris: $e');
      }
    } else {
      print('Utilisateur non connecté');
    }
  }

  // Fonction pour vérifier si une musique est dans les favoris
  Future<bool> isFavorite(String musiqueId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('utilisateurs')
            .doc(user.uid)
            .get();

        // Vérifie si l'ID de la musique existe dans la liste des favoris
        List<dynamic> favoris = doc['favoris'] ?? [];
        return favoris.contains(musiqueId);
      } catch (e) {
        print('Erreur vérification favoris: $e');
        return false;
      }
    } else {
      print('Utilisateur non connecté');
      return false;
    }
  }
}
