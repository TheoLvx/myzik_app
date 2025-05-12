import 'package:flutter/material.dart';

class MusicCard extends StatelessWidget {
  final String title;
  final String artist;
  final VoidCallback onPlay;

  const MusicCard({
    required this.title,
    required this.artist,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(artist),
        trailing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: onPlay,
        ),
      ),
    );
  }
}
