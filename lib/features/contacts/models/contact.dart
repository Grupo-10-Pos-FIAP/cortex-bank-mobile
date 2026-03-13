class Contact {
  final String id;
  final String name;
  bool isFavorite;
  bool isSelected;

  Contact({
    this.id = '',
    required this.name,
    this.isFavorite = false,
    this.isSelected = false,
  });

  factory Contact.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Contact(
      id: documentId,
      name: data['name'] as String? ?? '',
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'isFavorite': isFavorite,
  };
}
