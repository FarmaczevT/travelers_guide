import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/place_api.dart';
import '../models/place.dart';
import 'place_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Place> _places = [];
  String? _city;
  String? _category;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final placesString = prefs.getString('places');
    if (placesString != null) {
      final List<dynamic> placesJson = jsonDecode(placesString);
      setState(() {
        _places = placesJson.map((json) => Place.fromMap(json)).toList();
      });
    } else {
      print('Не найдено мест в SharedPreferences.');
    }
  }

  Future<void> _savePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> placesJson =
        _places.map((place) => place.toMap()).toList();
    await prefs.setString('places', jsonEncode(placesJson));
    print('Сохраненные места в SharedPreferences: $placesJson');
  }

  @override
  Widget build(BuildContext context) {
    print('Загружена страница с ${_places.length} мест');
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Справочник',
              style: TextStyle(fontSize: 25),
            ),
            if (_city != null && _category != null)
              const SizedBox(height: 5),
            if (_city != null && _category != null)
              Text(
                'Город: $_city, Категория: $_category',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _places.isEmpty
                ? const Center(
                    child: Text(
                        'Введите место и категорию, например:\nМесто - Москва \nКатегория - Ресторан'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      return GestureDetector(
                        onTap: () => _navigateToPlaceDetails(place),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 15.0),
                            leading: Icon(Icons.place, color: Theme.of(context).primaryColor, size: 30),
                            title: Text(
                              place.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Адрес: ${place.address}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(204, 0, 0, 0),
                                ),
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlaceDetails(Place place) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(place: place),
      ),
    );
    _loadPlaces(); // Загрузка мест после возврата с экрана деталей
  }

  Future<void> _showSearchDialog() async {
    String? city;
    String? category;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Поиск мест'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  city = value;
                },
                decoration: InputDecoration(
                  labelText: 'Место',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  category = value;
                },
                decoration: InputDecoration(
                  labelText: 'Категория',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                if (city != null &&
                    city!.isNotEmpty &&
                    category != null &&
                    category!.isNotEmpty) {
                      setState(() {
                        _city = city;
                        _category = category;
                      });
                    await _searchPlaces(city!, category!);
                }
                Navigator.of(context).pop();
              },
              child: Text('Поиск'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchPlaces(String city, String category) async {
    try {
      print('Поиск мест в $city с категорией $category');
      final results = await PlaceApi.searchPlaces(city, category);
      print('Найдено ${results.length} мест');
      setState(() {
        _places = results;
      });
      await _savePlaces(); // Сохраняем места после поиска
    } catch (e) {
      print(e);
    }
  }
}
