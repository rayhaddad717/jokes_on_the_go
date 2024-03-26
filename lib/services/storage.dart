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

enum STATISTICS { UPVOTE, DOWNVOTE, VIEWED_JOKES }

class StatisticsManager {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getKey(STATISTICS key) {
    switch (key) {
      case STATISTICS.UPVOTE:
        return "stat_upvotes";
      case STATISTICS.DOWNVOTE:
        return "stat_downvotes";
      case STATISTICS.VIEWED_JOKES:
        return "stat_viewed";
    }
  }

  //get a presaved score

  Future<int?> getStatistics(
    STATISTICS key,
  ) async {
    String keyAccess = getKey(key);
    return _prefs.getInt(keyAccess);
  }

  //set a score for a joke
  Future<void> setStatistics(STATISTICS key, int count) async {
    String keyAccess = getKey(key);
    await _prefs.setInt(keyAccess, count);
  }

  //increment a statistics
  Future<void> incrementKey(STATISTICS key, int count) async {
    int? result = await getStatistics(key);
    if (result == null)
      result = count;
    else {
      result += count;
    }
    await setStatistics(key, result);
  }

  //to clear all data
  Future<void> clearData() async {
    await _prefs.clear();
  }
}
