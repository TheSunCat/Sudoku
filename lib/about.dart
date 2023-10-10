import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sudoku/tutorial.dart';
import 'package:sudoku/ways_to_help.dart';

import 'custom_app_bar.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: DynamicColorTheme.of(context).isDark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Scaffold(
            body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: makeAppBar(context, "", null)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(children: [
                    const SizedBox(height: 25),
                    const Text(
                      "About Sud💜ku",
                      textScaleFactor: 2.5,
                    ),
                    const SizedBox(height: 25),
                    const Text("Thanks for playing! "),
                    const SizedBox(height: 20),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                'Version: ${snapshot.data!.version}',
                              ),
                            );
                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    getWaysToHelp(context),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const Tutorial()));
                      },
                      child: const Text("Replay tutorial"),
                    ),
                    TextButton(
                      onPressed: () => PackageInfo.fromPlatform()
                          .then((value) => showLicensePage(
                                context: context,
                                applicationName: "Sud💜ku",
                                applicationVersion: value.version,
                              )),
                      child: const Text("Show licenses"),
                    )
                  ]),
                ),
              ],
            ),
          ),
        )));
  }
}
