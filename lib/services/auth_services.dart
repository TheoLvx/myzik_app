import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour inscrire un nouvel utilisateur
  Future<User?> register(String email, String password, String name) async {
    try {
      // Création de l'utilisateur avec Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Une fois l'utilisateur créé, on récupère l'utilisateur
      User? user = result.user;

      // Ajouter les informations supplémentaires de l'utilisateur dans Firestore
      if (user != null) {
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'email': email,
          'name': name,
          'favorites': [], // Liste vide des favoris initialement
        });
      }

      return user;
    } catch (e) {
      print('Erreur inscription: $e');
      String errorMessage = 'Erreur inconnue.';

      // Gestion des erreurs Firebase
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Le mot de passe est trop faible.';
            break;
          case 'email-already-in-use':
            errorMessage = 'Cet email est déjà utilisé.';
            break;
          case 'invalid-email':
            errorMessage = 'L\'email est invalide.';
            break;
          default:
            errorMessage = e.message ?? 'Erreur inconnue.';
            break;
        }
      }
      return Future.error(errorMessage);
    }
  }

  // Méthode pour connecter un utilisateur
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Erreur connexion: $e');
      String errorMessage = 'Erreur inconnue.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Aucun utilisateur trouvé pour cet email.';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect.';
            break;
          case 'invalid-email':
            errorMessage = 'L\'email est invalide.';
            break;
          case 'invalid-credential':
            errorMessage = 'Les informations d\'authentification sont incorrectes ou ont expiré.';
            break;
          default:
            errorMessage = e.message ?? 'Erreur inconnue.';
            break;
        }
      }
      return Future.error(errorMessage);
    }
  }

  // Méthode pour déconnecter un utilisateur
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Méthode pour récupérer l'utilisateur actuellement connecté
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Méthode pour vérifier si un utilisateur est authentifié
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
