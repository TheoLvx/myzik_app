import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import '../models/musique.dart';
import '../widgets/custom_drawer.dart';

class PlayerScreen extends StatefulWidget {
  final Musique musique;

  const PlayerScreen({Key? key, required this.musique}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
  }

  // Initialisation du lecteur audio
  Future<void> _initializePlayer() async {
    try {
      await _player.setUrl(widget.musique.audioUrl);
      // Vérification de la durée
      _duration = _player.duration ?? Duration.zero;

      _player.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      print("Erreur de lecture : $e");
    }
  }


  // Fonction pour obtenir la position de l'utilisateur et l'enregistrer
  Future<void> _getLocationAndLog() async {
    // Appel au service de géolocalisation pour récupérer la position
    Position? position = await _locationService.getCurrentPosition();

    if (position != null) {
      print('Position actuelle: ${position.latitude}, ${position.longitude}');

      // Sauvegarde la position dans Firestore
      await _logLocation(position);
    } else {
      print('Permission de localisation refusée ou position non disponible');
    }
  }

  // Fonction pour enregistrer la position dans Firestore
  Future<void> _logLocation(Position position) async {
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


  // Fonction pour jouer / mettre en pause la musique
  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  // Fonction pour ajouter aux favoris
  Future<void> _addToFavorites() async {
    await _favoritesService.addToFavorites(widget.musique.id);
  }

  // Fonction pour vérifier si la musique est déjà dans les favoris
  Future<bool> _isMusicInFavorites() async {
    return await _favoritesService.isFavorite(widget.musique.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lecteur de musique')),
      drawer: CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Affichage de l'image de couverture si disponible
          widget.musique.imageUrl != null
              ? Image.network(widget.musique.imageUrl!)
              : SizedBox.shrink(),
          // Affichage du titre et de l'artiste
          Text(widget.musique.titre, style: TextStyle(fontSize: 24)),
          Text(widget.musique.artiste, style: TextStyle(fontSize: 18)),

          // Barre de progression
          Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble(),
            onChanged: (value) {
              setState(() {
                _player.seek(Duration(seconds: value.toInt()));
              });
            },
          ),

          // Affichage du temps de lecture
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_position.toString().split('.').first),
              Text(_duration.toString().split('.').first),
            ],
          ),

          // Bouton Play/Pause
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
            iconSize: 50,
          ),

          // Bouton Ajouter aux favoris
          ElevatedButton(
            onPressed: _addToFavorites,
            child: FutureBuilder<bool>(
              future: _isMusicInFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return Text('Déjà dans les favoris');
                } else {
                  return Text('Ajouter aux favoris');
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: _togglePlayPause,
            child: Text(_isPlaying ? 'Pause' : 'Lecture'),
          ),
          SizedBox(height: 20),
          Text(
            "Position actuelle: ${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 18),
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _getLocationAndLog,
            child: Text('Enregistrer ma position'),
          ),
        ],
      ),
    );
  }
}
