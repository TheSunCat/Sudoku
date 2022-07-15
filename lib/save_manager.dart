import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/util.dart';
import 'dart:convert';

import 'package:sudoku_api/sudoku_api.dart';

class SaveManager {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final SaveManager _instance = SaveManager._internal();

  factory SaveManager() {
    return _instance;
  }

  SaveManager._internal();

  Future<bool> saveExists(int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.containsKey("board$difficulty");
  }

  void save(int difficulty, Puzzle data) async {
    final SharedPreferences prefs = await _prefs;

    await prefs.setString("board$difficulty", json.encode(data.toMap()));
  }

  Future<Puzzle> load(int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    String jsonData = prefs.getString("board$difficulty")!;

    return Puzzle.fromMap(json.decode(jsonData));
  }

  void clear(int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    prefs.remove("board$difficulty");
  }

  // scores are stringified as yMd#time

  void recordScore(Duration time, int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    List<String> scores = prefs.getStringList("scores$difficulty") ?? List<String>.empty(growable: true);

    // delete invalid entries
    scores.removeWhere((string) => !string.contains('#'));

    DateTime now = DateTime.now();
    scores.add("${now.day} ${DateFormat.yMMM().format(now)}#${time.inSeconds}");

    scores.sort((String a, String b) =>
        int.parse(a.substring(a.indexOf('#') + 1, a.length)).compareTo(int.parse(b.substring(b.indexOf('#') + 1, b.length)))
    );

    if(scores.length > 10) {
      scores.removeRange(9, scores.length - 1);
    }

    prefs.setStringList("scores$difficulty", scores);
  }

  Future<List<Score>> getScores(int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    List<String> scores = prefs.getStringList("scores$difficulty") ?? List<String>.empty();

    // delete invalid entries
    scores.removeWhere((string) => !string.contains('#'));

    List<Score> ret = List<Score>.empty(growable: true);

    for(int i = 0; i < scores.length; i++) {
      ret.add(
        Score(
          Duration(seconds: int.parse(scores[i].substring(
              scores[i].indexOf('#') + 1, scores[i].length))),
          scores[i].substring(0, scores[i].indexOf('#'))
        )
      );
    }

    return ret;
  }
}

class Score {
  Duration time;
  String date;

  Score(this.time, this.date);
}