class Resource {
  String id;
  String name;
  String category;
  String description;
  double latitude;
  double longitude;
  bool isAvailable;
  String owner;
  String organization;
  DateTime createdAt;

  Resource({
    this.id = '',
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.owner,
    required this.organization,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'owner': owner,
      'organization': organization,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Resource fromMap(Map<String, dynamic> map, String id) {
    return Resource(
      id: id,
      name: map['name'],
      category: map['category'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isAvailable: map['isAvailable'],
      owner: map['owner'],
      organization: map['organization'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}