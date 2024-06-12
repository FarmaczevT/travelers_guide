import 'package:flutter/material.dart';
import '../models/place.dart';
import 'place_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Place> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    print("Загруженные избранные: $favorites");
    setState(() {
      _favorites = favorites.map((json) => Place.fromMap(jsonDecode(json))).toList();
    });
  }

  Future<void> _removeFromFavorites(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    final placeJson = jsonEncode(place.toMap());
    favorites.remove(placeJson);
    await prefs.setStringList('favorites', favorites);
    setState(() {
      _favorites.remove(place);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final place = _favorites[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(place: place),
              ),
            ),
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _removeFromFavorites(place);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
