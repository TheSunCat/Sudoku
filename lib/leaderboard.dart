import 'package:flutter/material.dart';
import 'package:sudoku/util.dart';

import 'save_manager.dart';

Widget makeLeaderboard(BuildContext context, List<Score> scores, { String highlightTime = "none" })
{
  bool alreadyHighlighted = false;

  return scores.isEmpty ?
    const Text("No scores yet.")
    : SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: scores.map((score) {
          bool highlight = false;

          if(!alreadyHighlighted && highlightTime == timeToString(score.time)) {
            alreadyHighlighted = true;
            highlight = true;
          }

          return Container(
            padding: const EdgeInsets.all(5),
            color: highlight ? Theme.of(context).primaryColor : Colors.transparent,
            child: DefaultTextStyle(
              style: TextStyle(
                color: highlight
                    ? Theme.of(context).canvasColor
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                  [
                    Text("${scores.indexOf(score) + 1}. ${score.date}"),

                    Text(timeToString(score.time)),
                  ]
              ),
            ),
          );
        }).toList(),
      ),
  );
}

