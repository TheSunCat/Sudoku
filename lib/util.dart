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
  if (time.inSeconds != 0) {
    timeString += "${time.inSeconds % 60}S";
  }

  return timeString;
}