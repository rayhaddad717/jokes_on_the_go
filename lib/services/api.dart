import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/joke.dart';

class API {
  final limit = 8;
  static int lastPage = 0;
  static Map<int, List<Joke>> cache = {};

  Future<List<Joke>> fetchJokes(int pageNumber) async {
    if (cache.containsKey(pageNumber)) {
      //cache the results of the api
      return Future.value(cache[pageNumber]);
    }
    final response = await http.get(
        Uri.parse(
            'https://icanhazdadjoke.com/search?page=$pageNumber&limit=$limit'),
        headers: {
          'Accept': 'application/json',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(response.body);
      List<dynamic> jsonList = body['results'];
      final jokeList = jsonList.map((e) => Joke.fromJson(e)).toList();
      if (lastPage < pageNumber) lastPage = pageNumber;
      cache.putIfAbsent(pageNumber, () => jokeList);
      return jokeList;
    } else {
      return [];
    }
  }
}
