import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sudoku/game_board.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/sudoku.dart';
import 'package:sudoku/ways_to_help.dart';

import 'fade_dialog.dart';
import 'home_page.dart';

class Tutorial extends StatefulWidget {
  static String id = 'Tutorial';

  const Tutorial({super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final PageController _pageController = PageController();
  final int _lastPageIndex = 2;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    });
  }

  void close() {
    SaveManager().markTutorialSeen(true);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getPage(index),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
              onPressed: (_currentPage == 0) ? null : () => changePage(-1),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) =>
                      states.contains(WidgetState.disabled)
                          ? Colors.black
                          : Theme.of(context).colorScheme.primary,
                ),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: const Icon(Icons.arrow_left),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: _lastPageIndex + 1,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotHeight: 16,
                dotWidth: 16,
              ),
            ),
            TextButton(
              onPressed:
                  (_currentPage == _lastPageIndex) ? null : () => changePage(1),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) =>
                      states.contains(WidgetState.disabled)
                          ? Colors.black
                          : Theme.of(context).colorScheme.primary,
                ),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: const Icon(Icons.arrow_right),
            ),
          ]),
          const SizedBox(height: 10)
        ],
      ),
      Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: CloseButton(
              onPressed: () => close(),
            ),
          ))
    ]));
  }

  void changePage(int delta) {
    _pageController.animateToPage(_currentPage + delta,
        duration: const Duration(milliseconds: 400), curve: Curves.decelerate);
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return page1();
      case 1:
        return page2();
      case 2:
        return page3();
    }

    return const Icon(Icons.error);
  }

  Widget page1() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(500)
              //more than 50% of width makes circle
              ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: CustomPaint(
              size: Size(screenWidth * .50, screenWidth * .50),
              painter: LogoPainter(Theme.of(context).colorScheme.surface),
            ),
          ),
        ),
        const SizedBox(height: 50),
        Text(
          "Welcome to Sud💜ku!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 25),
        const Text(
            "The following is a short introduction to the game.\nIf you already know how to play, feel free to press skip!",
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        Column(
          children: [
            OutlinedButton(
              onPressed: () async {
                changePage(1);
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).textTheme.bodyMedium!.color!),
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).primaryColor.withAlpha(200)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Continue", style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                _pageController.animateToPage(_lastPageIndex,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.decelerate);
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).textTheme.bodyMedium!.color!),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Skip", style: TextStyle(fontSize: 20)),
              ),
            )
          ],
        ),
      ],
    );
  }

  final GlobalKey<GameBoardState> _gameBoard = GlobalKey();
  int _selectedNum = -1;
  Widget page2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 600,
          child: GameBoard(
            key: _gameBoard,
            emptySquares: 1,
            onBoardChanged: onBoardChanged,
            onCellTapped: onCellTapped,
            onGameWon: onGameWon,
            marking: false,
            onReady: onReady,
            highlightNum: _selectedNum,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Every row, column, and 3x3 box must contain every number from 1-9.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          "Select a number below, then tap an empty cell to fill it in.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          "You can also tap a filled-in cell to select its number.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemBuilder: _buildNumberButton,
            itemCount: 10,
            primary: true, // disable scrolling
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, int index) {
    int selectedIndex = _selectedNum - 1;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(300),
          color: selectedIndex == index
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
        ),
        child: OutlinedButton(
          onPressed: () {
            numberButtonTapped(index);
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(300.0))),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text((index == 9) ? "X" : (index + 1).toString(),
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      ),
    );
  }

  void numberButtonTapped(int index) {
    int valTapped = index + 1;

    if (_selectedNum == valTapped) {
      setState(() => _selectedNum = -1);
    } else {
      setState(() => _selectedNum = valTapped);
    }
  }

  Widget page3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Text(
          "Now you're ready to play!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 50),
        getWaysToHelp(context),
        const SizedBox(height: 75),
        OutlinedButton(
          onPressed: () async {
            close();
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
            foregroundColor: WidgetStateProperty.all(
                Theme.of(context).textTheme.bodyMedium!.color!),
            backgroundColor: WidgetStateProperty.all(
                Theme.of(context).primaryColor.withAlpha(200)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Maybe later", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  void onBoardChanged(List<List<Cell>> board) {
    _gameBoard.currentState!.validate();
  }

  void onCellTapped(Cell cell) {
    if (_selectedNum == -1) {
      setState(() => _selectedNum = cell.value);
    }
  }

  void onGameWon(BuildContext context) {
    fadePopup(
        context,
        AlertDialog(
          title: const Center(child: Text("Success!")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("You solved the tutorial puzzle."),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      changePage(1);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                    ),
                    child: const Text("Next")),
              ),
            ],
          ),
        ));
  }

  void onReady() {}
}
