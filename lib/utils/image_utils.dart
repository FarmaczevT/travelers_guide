import 'package:http/http.dart' as http;

Future<bool> imageExists(String imageUrl) async {
  final response = await http.head(Uri.parse(imageUrl));
  return response.statusCode == 200;
}
