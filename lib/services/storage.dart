import 'package:shared_preferences/shared_preferences.dart';

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
