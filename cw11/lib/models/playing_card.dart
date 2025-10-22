class PlayingCard {
  int? id;
  String name;
  String suit;
  String imageUrl;
  String? imageBytes; // base64 string
  int? folderId;
  DateTime createdAt;

  PlayingCard({
    this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    this.imageBytes,
    this.folderId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'folderId': folderId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlayingCard.fromMap(Map<String, dynamic> map) {
    return PlayingCard(
      id: map['id'] as int?,
      name: map['name'] as String,
      suit: map['suit'] as String,
      imageUrl: map['imageUrl'] as String,
      imageBytes: map['imageBytes'] as String?,
      folderId: map['folderId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}


