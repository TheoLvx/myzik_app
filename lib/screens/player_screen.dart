import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/favorites_service.dart';
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

  Future<void> _loadFavoriteStatus() async {
    final result = await _favoritesService.isFavorite(widget.musique.id);
    setState(() {
      _isFavorite = result;
    });
  }

  Future<void> _addToFavorites() async {
    await _favoritesService.addToFavorites(widget.musique.id);

    final musiqueDoc = FirebaseFirestore.instance
        .collection('musiques')
        .doc(widget.musique.id);

    final doc = await musiqueDoc.get();
    if (!doc.exists) {
      await musiqueDoc.set({
        'titre': widget.musique.titre,
        'artiste': widget.musique.artiste,
        'audioUrl': widget.musique.audioUrl,
        'imageUrl': widget.musique.imageUrl,
      });
      print('✅ Musique enregistrée dans Firestore');
    } else {
      print('ℹ️ Musique déjà présente dans Firestore');
    }

    _loadFavoriteStatus();
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
          widget.musique.imageUrl.isNotEmpty
              ? Image.network(widget.musique.imageUrl)
              : SizedBox.shrink(),

          SizedBox(height: 16),
          Text(widget.musique.titre, style: TextStyle(fontSize: 24)),
          Text(widget.musique.artiste, style: TextStyle(fontSize: 18)),

          SizedBox(height: 16),
          Slider(
            value: _duration.inSeconds > 0
                ? _position.inSeconds.clamp(0, _duration.inSeconds).toDouble()
                : 0.0,
            max: _duration.inSeconds > 0
                ? _duration.inSeconds.toDouble()
                : 1.0,
            onChanged: _duration.inSeconds > 0
                ? (value) => _player.seek(Duration(seconds: value.toInt()))
                : null,
          ),

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

          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 50,
            onPressed: _togglePlayPause,
          ),

          SizedBox(height: 16),
          _isFavorite == null
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _isFavorite! ? null : _addToFavorites,
            child: Text(
              _isFavorite! ? 'Déjà dans les favoris' : 'Ajouter aux favoris',
            ),
          ),

          SizedBox(height: 20),
          Text(
            "Position : ${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
