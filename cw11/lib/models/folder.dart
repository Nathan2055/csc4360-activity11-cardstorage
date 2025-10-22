class Folder {
  int? id;
  String name;
  String? previewImage;
  DateTime createdAt;

  Folder({
    this.id,
    required this.name,
    this.previewImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'previewImage': previewImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      name: map['name'] as String,
      previewImage: map['previewImage'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}


