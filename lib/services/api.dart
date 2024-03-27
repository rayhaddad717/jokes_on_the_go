import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:jokes_on_the_go/services/storage.dart';
import '../components/joke.dart';

class API {
  final limit = 8;
  static int lastPage = 0;
  static Map<int, List<Joke>> cache = {};
  final StatisticsManager _statisticsManager = StatisticsManager();

  API() {
    _statisticsManager.init();
  }

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
      //update the number of views jokes
      _statisticsManager.incrementKey(STATISTICS.VIEWED_JOKES, jokeList.length);
      cache.putIfAbsent(pageNumber, () => jokeList);
      return jokeList;
    } else {
      return [];
    }
  }
}
