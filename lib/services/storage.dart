import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../components/joke.dart';

//this class is used to save the joke scores for future use
class ScoreManager {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //get a score for an existing joke
  Future<int?> getScoreForId(String id) async {
    return _prefs.getInt('score_$id');
  }

  //set a score for a joke
  Future<void> setScoreForId(String id, int score) async {
    await _prefs.setInt('score_$id', score);
  }
}

//this function is used to save favorite jokes to local storage
class JokeManager {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //this function is used to save a joke to our favorites
  void saveFavJokesToLocal(Joke joke) async {
    //get all previously saved jokes
    List<Joke> fav_jokes = await fetchFavJokesFromLocal();
    var findJoke = fav_jokes.where((element) => element.id == joke.id).toList();
    if (findJoke.isNotEmpty) {
      //joke already in favorites
      return;
    }
    fav_jokes.add(joke);
    List<String> jsonJokes =
    fav_jokes.map((joke) => jsonEncode(joke.toJson())).toList();
    _prefs.setStringList('fav_jokes', jsonJokes);
  }

  //this function is used to fetch all favorites jokes on our device
  Future<List<Joke>> fetchFavJokesFromLocal() async {
    List<String>? jsonJokes = _prefs.getStringList('fav_jokes');

    if (jsonJokes != null) {
      List<Joke> jokes = jsonJokes.map((jsonJoke) {
        Map<String, dynamic> decodedJoke = jsonDecode(jsonJoke);
        return Joke.fromJson(decodedJoke);
      }).toList();

      return jokes;
    } else {
      return [];
    }
  }
}
