import 'package:flutter/material.dart';
import 'package:sudoku/util.dart';

import 'l10n/app_localizations.dart';

Widget getWaysToHelp(BuildContext context) {
  return Column(children: [
    Text(
        AppLocalizations.of(context)!.aboutFossNotice("Sud💜ku"),
        textAlign: TextAlign.center),
    const SizedBox(height: 10),
    Text(
        AppLocalizations.of(context)!.aboutContributionsAppreciated,
        textAlign: TextAlign.center),
    const SizedBox(height: 10),
    Text(AppLocalizations.of(context)!.aboutWaysToHelp, textAlign: TextAlign.center),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code),
            const SizedBox(width: 5),
            Text(AppLocalizations.of(context)!.aboutSubmitPatch, style: const TextStyle(fontSize: 20)),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_money),
            const SizedBox(width: 5),
            Text(AppLocalizations.of(context)!.aboutDonate, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    ),
  ]);
}
