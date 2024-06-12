import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  PlaceDetailsScreen({required this.place});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isLoading = true;
  late Map<String, dynamic> _placeDetails;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _placeDetails = widget.place.toMap();
    print("Place details loaded: $_placeDetails");
    setState(() {
      _isLoading = false;
    });
    _checkFavoriteStatus();
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    final placeJson = jsonEncode(widget.place.toMap());

    setState(() {
      if (_isFavorite) {
        favorites.remove(placeJson);
        _isFavorite = false;
      } else {
        favorites.add(placeJson);
        _isFavorite = true;
      }
    });

    await prefs.setStringList('favorites', favorites);
  }

  void _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    final placeJson = jsonEncode(widget.place.toMap());
    setState(() {
      _isFavorite = favorites.contains(placeJson);
    });
  }

  String get _isFavoriteText => _isFavorite ? "Убрать из избранного" : "Добавить в избранное";

  void _openMap() {
    final latitude = widget.place.latitude;
    final longitude = widget.place.longitude;
    final url = 'https://yandex.ru/maps/?pt=$longitude,$latitude&z=16&l=map';
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Адрес: ${_placeDetails['address'] ?? ''}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16.0),
                  if (_placeDetails['categories'] != null &&
                      _placeDetails['categories'].isNotEmpty)
                    Text(
                      'Категории: ${(_placeDetails['categories'] as List<dynamic>).join(', ')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16.0),
                  if (_placeDetails['url'] != null &&
                      _placeDetails['url'].isNotEmpty)
                    Row(children: [
                      const Text(
                        'Сайт: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          launch(_placeDetails['url']);
                        },
                        child: const Text(
                          'Перейти на сайт',
                          style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                      )
                    ]),
                  const SizedBox(height: 16.0),
                  if (_placeDetails['phones'] != null &&
                      _placeDetails['phones'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _placeDetails['phones'].map<Widget>((phone) {
                        return Row(
                          children: [
                            const Text(
                              'Телефон: ',
                              style: TextStyle(fontSize: 18),
                            ),
                            GestureDetector(
                              onTap: () {
                                launch("tel:$phone");
                              },
                              child: Text(
                                phone,
                                style: const TextStyle(
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16.0),
                  if (_placeDetails['hours'] != null &&
                      _placeDetails['hours'].isNotEmpty)
                    Text(
                      'Часы работы: ${(_placeDetails['hours'])}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16.0),
                   ElevatedButton(
                    onPressed: _openMap,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Открыть карту',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : null,
                        ),
                        label: Text(
                          _isFavoriteText,
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
