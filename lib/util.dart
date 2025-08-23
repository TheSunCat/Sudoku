import 'package:sudoku/sudoku.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: maybe localize this
String timeToString(Duration time) {
  String timeString = "";

  if (time.inDays != 0) {
    timeString += "${time.inDays}D ";
  }
  if (time.inHours != 0) {
    timeString += "${time.inHours % 24}H ";
  }
  if (time.inMinutes != 0) {
    timeString += "${time.inMinutes % 60}M ";
  }
  if (time.inSeconds >= 0) {
    timeString += "${time.inSeconds % 60}S";
  }

  return timeString;
}

int difficultyToEmptySquares(int difficulty)
{
  // TODO: can we make this more difficult?
  int clues = (Sudoku.numDifficulties - difficulty) * 6;
  return 60 - clues;
}

Future<void> launchURL(String url) async
{
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}