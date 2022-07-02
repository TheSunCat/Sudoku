
import 'package:flutter/material.dart';

Widget makeAppBar(BuildContext context, String center, Widget? right) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
          color: Theme.of(context).textTheme.bodyMedium!.color!,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back)
      ),
      Text(center, style: Theme.of(context).textTheme.bodyMedium),
      right ?? IconButton( // place secret icon to center text
              enableFeedback: false,
              color: Theme.of(context).canvasColor,
              onPressed: () => {},
              icon: const Icon(Icons.arrow_forward),
              splashRadius: 1,
            ),
    ],
  );
}