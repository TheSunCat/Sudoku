import 'package:flutter/material.dart';

void fadeDialog(BuildContext context, String content, String no, String yes, void Function()? onNo, void Function()? onYes)
{
  showGeneralDialog(
    context: context,
    pageBuilder: (ctx, a1, a2) {
      return Container();
    },
    transitionBuilder: (ctx, a1, a2, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeOutCirc;

      final tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: a1,
        curve: curve,
      );

      final opacity = CurvedAnimation(parent: a1, curve: curve);

      return FadeTransition(
        opacity: opacity,
        child: SlideTransition(
          position: tween.animate(curvedAnimation),
          child: AlertDialog(
            //title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if(onNo != null) {
                      onNo();
                    }
                  },
                  child: Text(no),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if(onYes != null) {
                      onYes();
                    }
                  },
                  child: Text(yes),
              ),
            ],
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}