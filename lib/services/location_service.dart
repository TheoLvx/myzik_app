import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Demander la permission et récupérer la position
  Future<Position?> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Si la permission est refusée
      return null;
    } else {
      // Si la permission est accordée, récupérer la position
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }

  // Enregistrer la position dans Firestore
  Future<void> logLocation(Position position) async {
    try {
      await FirebaseFirestore.instance.collection('ecoutes').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': FirebaseAuth.instance.currentUser?.uid, // ID de l'utilisateur connecté
      });
      print("Position enregistrée dans Firestore");
    } catch (e) {
      print("Erreur lors de l'enregistrement de la position: $e");
    }
  }
}
