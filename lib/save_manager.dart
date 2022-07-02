import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
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

    await prefs.setString("board$difficulty", json.encode(data));
  }

  Future<Puzzle> load(int difficulty) async {
    final SharedPreferences prefs = await _prefs;

    String jsonData = prefs.getString("board$difficulty")!;
    log(jsonData);

    return json.decode(jsonData);
  }
}