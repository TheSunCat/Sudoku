import 'package:flutter/material.dart';
import 'package:sudoku/util.dart';

Widget getWaysToHelp(BuildContext context) {
  return Column(children: [
    const Text(
        "Sud💜ku is open source software. No user data is collected, and the game is made available free of charge for everyone.",
        textAlign: TextAlign.center),
    const SizedBox(height: 10),
    const Text(
        "Development and maintenance of this application takes many hours of work, and any contribution is vastly appreciated!",
        textAlign: TextAlign.center),
    const SizedBox(height: 10),
    const Text("Here are some ways you can help:", textAlign: TextAlign.center),
    const SizedBox(height: 40),
    OutlinedButton(
      onPressed: () async {
        launchURL("https://github.com/TheSunCat/Sudoku");
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
        foregroundColor: WidgetStateProperty.all(
            Theme.of(context).textTheme.bodyMedium!.color!),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code),
            SizedBox(width: 5),
            Text("Submit a patch", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    ),
    const SizedBox(height: 10),
    OutlinedButton(
      onPressed: () async {
        launchURL("https://allpurposem.at/link/donate");
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
        foregroundColor: WidgetStateProperty.all(
            Theme.of(context).textTheme.bodyMedium!.color!),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money),
            SizedBox(width: 5),
            Text("Donate", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    ),
  ]);
}
