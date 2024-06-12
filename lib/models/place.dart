class Place {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String url;
  final List<String> phones;
  final List<String> categories;
  final String hours;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.url,
    required this.phones,
    required this.categories,
    required this.hours,
  });

  factory Place.fromMap(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      url: json['url'],
      phones: List<String>.from(json['phones'] as List),
      categories: List<String>.from(json['categories'] as List),
      hours: json['hours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'url': url,
      'phones': phones,
      'categories': categories,
      'hours': hours,
    };
  }
}

// factory Place.fromMap(Map<String, dynamic> json) {
//     final properties = json['properties'] ?? {};
//     final geometry = json['geometry'] ?? {};
//     final coordinates = geometry['coordinates'] ?? [0.0, 0.0];
//     final companyMetaData = properties['CompanyMetaData'] ?? {};
//     final hours = companyMetaData['Hours']?['text'] ?? '';

//     final phones = (companyMetaData['Phones'] as List<dynamic>?)
//         ?.map((phone) => phone['formatted'] ?? '')
//         .toList() ?? [];
    
//     final categories = (companyMetaData['Categories'] as List<dynamic>?)
//         ?.map((category) => '${category['name']} (${category['class']})')
//         .toList() ?? [];

//     return Place(
//       id: companyMetaData['id'] ?? '',
//       name: properties['name'] ?? '',
//       address: properties['description'] ?? '',
//       latitude: (coordinates.length > 1) ? coordinates[1] : 0.0,
//       longitude: (coordinates.length > 0) ? coordinates[0] : 0.0,
//       url: companyMetaData['url'] ?? '',
//       phones: phones.cast<String>(),
//       categories: categories.cast<String>(),
//       hours: hours ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'address': address,
//       'latitude': latitude,
//       'longitude': longitude,
//       'url': url,
//       'phones': phones,
//       'categories': categories,
//       'hours': hours,
//     };
//   }
//   factory Place.fromJson(String source) => Place.fromMap(json.decode(source));
// }