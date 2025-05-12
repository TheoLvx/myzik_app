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
  bool? _isFavorite;
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.setUrl(widget.musique.audioUrl);

      // Écoute la durée quand elle est dispo
      _player.durationStream.listen((newDuration) {
        if (newDuration != null) {
          setState(() {
            _duration = newDuration;
          });
        }
      });

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

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> _getLocationAndLog() async {
    Position? position = await _locationService.getCurrentPosition();
    if (position != null) {
      await _logLocation(position);
    }
  }

  Future<void> _logLocation(Position position) async {
    try {
      await FirebaseFirestore.instance.collection('ecoutes').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': FirebaseAuth.instance.currentUser?.uid,
      });
      print("Position enregistrée dans Firestore");
    } catch (e) {
      print("Erreur lors de l'enregistrement de la position: $e");
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final result = await _favoritesService.isFavorite(widget.musique.id);
    setState(() {
      _isFavorite = result;
    });
  }

  Future<void> _addToFavorites() async {
    await _favoritesService.addToFavorites(widget.musique.id);
    _loadFavoriteStatus(); // rafraîchit l’état
  }

  @override
  Widget build(BuildContext context) {
    final formattedPosition = _position.toString().split('.').first;
    final formattedDuration = _duration.toString().split('.').first;

    return Scaffold(
      appBar: AppBar(title: Text('Lecteur de musique')),
      drawer: CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          widget.musique.imageUrl.isNotEmpty
              ? Image.network(widget.musique.imageUrl)
              : SizedBox.shrink(),

          SizedBox(height: 16),

          // Titre et artiste
          Text(widget.musique.titre, style: TextStyle(fontSize: 24)),
          Text(widget.musique.artiste, style: TextStyle(fontSize: 18)),

          SizedBox(height: 16),

          // Slider sécurisé
          Slider(
            value: _duration.inSeconds > 0
                ? _position.inSeconds.clamp(0, _duration.inSeconds).toDouble()
                : 0.0,
            max: _duration.inSeconds > 0
                ? _duration.inSeconds.toDouble()
                : 1.0,
            onChanged: _duration.inSeconds > 0
                ? (value) {
              _player.seek(Duration(seconds: value.toInt()));
            }
                : null,
          ),

          // Durée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(formattedPosition),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(formattedDuration),
              ),
            ],
          ),

          // Lecture / Pause
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 50,
            onPressed: _togglePlayPause,
          ),

          SizedBox(height: 16),

          // Bouton favoris optimisé
          _isFavorite == null
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _isFavorite! ? null : _addToFavorites,
            child: Text(_isFavorite!
                ? 'Déjà dans les favoris'
                : 'Ajouter aux favoris'),
          ),

          SizedBox(height: 8),

          // Bouton Lecture
          ElevatedButton(
            onPressed: _togglePlayPause,
            child: Text(_isPlaying ? 'Pause' : 'Lecture'),
          ),

          SizedBox(height: 20),

          // Position texte
          Text(
            "Position actuelle : ${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 18),
          ),

          SizedBox(height: 20),

          // Enregistrement position
          ElevatedButton(
            onPressed: _getLocationAndLog,
            child: Text('Enregistrer ma position'),
          ),
        ],
      ),
    );
  }
}
