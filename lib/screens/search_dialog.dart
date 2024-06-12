import 'package:flutter/material.dart';

class SearchDialog extends StatefulWidget {
  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Поиск мест'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _placeController,
            decoration: InputDecoration(hintText: 'Место'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: 'Категория'),
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
          onPressed: () {
            final place = _placeController.text;
            final category = _categoryController.text;
            if (place.isNotEmpty && category.isNotEmpty) {
              Navigator.of(context).pop();
            }
          },
          child: Text('ОК'),
        ),
      ],
    );
  }
}
