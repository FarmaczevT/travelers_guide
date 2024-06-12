import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlaceApi {
  static const String _baseUrl = 'https://search-maps.yandex.ru/v1/';
  static const String _apiKey = '7e4e55b4-7bfb-4c3d-abfb-ca0109576f5b';

  static Future<List<Place>> searchPlaces(String city, String category) async {
  // final coordinates = await _getCoordinates(city);
  // print('Coordinates: $coordinates');
  final response = await http.get(Uri.parse(
    // '$_baseUrl?text=$category&type=biz&lang=ru_RU&results=20&apikey=$_apiKey&ll=$coordinates&spn=0.552069,0.400552',
    '$_baseUrl?text=$city,$category&type=biz&lang=ru_RU&results=50&apikey=$_apiKey',
  ));

  if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Response body: $json');
      final List<dynamic> items = json['features'] ?? [];
      final List<Place> places = items.map((item) {
        final properties = item['properties'] ?? {};
        final geometry = item['geometry'] ?? {};
        final coordinates = geometry['coordinates'] ?? [0.0, 0.0];

        final companyMetaData = properties['CompanyMetaData'] ?? {};

        // Debugging null values
        if (companyMetaData.isEmpty) print('companyMetaData is null');
        if (properties['name'] == null) print('name is null');
        if (properties['description'] == null) print('description is null');
        if (coordinates.length < 2) print('coordinates are incomplete');

        final phones = (companyMetaData['Phones'] as List<dynamic>?)
            ?.map((phone) => phone['formatted'] ?? '')
            .toList() ?? [];
        
        final categories = (companyMetaData['Categories'] as List<dynamic>?)
            ?.map((category) => '${category['name']} (${category['class']})')
            .toList() ?? [];

        final hours = companyMetaData['Hours']?['text'] ?? '';

        return Place(
          id: companyMetaData['id'] ?? '',
          name: properties['name'] ?? '',
          address: properties['description'] ?? '',
          latitude: (coordinates.length > 1) ? coordinates[1] : 0.0,
          longitude: (coordinates.length > 0) ? coordinates[0] : 0.0,
          url: companyMetaData['url'] ?? '',
          phones: phones.cast<String>(),
          categories: categories,
          hours: hours ?? '',
        );
      }).toList();

      print('Found ${places.length} places');
      return places;
    } else {
      throw Exception('Failed to search places');
    }
  }

  // Function to get coordinates of the city
  // static Future<String> _getCoordinates(String city) async {
  //   final query = Uri.encodeComponent(city);
  //   final response = await http.get(Uri.parse(
  //     'https://geocode-maps.yandex.ru/1.x/?geocode=$query&format=json&apikey=2ed5e523-e82d-485b-99e7-a85c6776023e',
  //   ));

  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //     print('Geocode response body: $json');
  //     final List<dynamic> items = json['response']['GeoObjectCollection']['featureMember'];
  //     if (items.isNotEmpty) {
  //       final item = items[0];
  //       final point = item['GeoObject']['Point']['pos'].split(' ');
  //       final latitude = point[1];
  //       final longitude = point[0];
  //       return '$latitude,$longitude';
  //     }
  //   }

  //   throw Exception('Failed to get coordinates');
  // }
}
