class Musique {
  final String id;
  final String titre;
  final String artiste;
  final String audioUrl;
  final String imageUrl;

  Musique({
    required this.id,
    required this.titre,
    required this.artiste,
    required this.audioUrl,
    required this.imageUrl,
  });

  factory Musique.fromMap(Map<String, dynamic> data, String id) {
    return Musique(
      id: id,
      titre: data['titre'] ?? '',
      artiste: data['artiste'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
