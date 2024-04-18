// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/sudoku.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum Difficulty { easy, medium, hard }

void main() {
  runApp(
    MaterialApp(
      home: const SudokuApp(),
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
    ),
  );
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  int pageIndex = 0;
  int activeCellID = 1;
  int activeCellIDSolve = 1;
  int timeElapsed = 0;
  bool completed = true;
  Difficulty difficultySelected = Difficulty.easy;
  Difficulty generatedDifficulty = Difficulty.easy;
  SudokuBoard board = SudokuBoard();
  SudokuBoard boardToSolve = SudokuBoard();
  bool notesMode = false;
  FocusNode focusNode = FocusNode();
  final List<String> numList = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  bool timerPaused = true;
  bool solveInputEnabled = true;
  bool boardSolved = false;
  List<int> shadedCellIDs = [
    1,
    2,
    3,
    7,
    8,
    9,
    10,
    11,
    12,
    16,
    17,
    18,
    19,
    20,
    21,
    25,
    26,
    27,
    31,
    32,
    33,
    40,
    41,
    42,
    49,
    50,
    51,
    55,
    56,
    57,
    61,
    62,
    63,
    64,
    65,
    66,
    70,
    71,
    72,
    73,
    74,
    75,
    79,
    80,
    81
  ];
  Uri sourceUri = Uri.parse("https://github.com/debord555/sudoku");

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!timerPaused) {
          if (!completed) {
            setState(() {
              timeElapsed++;
            });
          } else {
            timerPaused = true;
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) => AlertDialog(
                icon: const Icon(Icons.celebration),
                title: const Text("Congratulations!"),
                // ignore: prefer_interpolation_to_compose_strings
                content: Text("You have completed this " +
                    ((generatedDifficulty == Difficulty.easy) ? "easy" : ((generatedDifficulty == Difficulty.medium) ? "medium" : "hard")) +
                    " difficulty puzzle."),
                actions: [
                  TextButton(
                    child: const Text("Thanks!"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  void updatePageIndex(int i) {
    setState(() {
      pageIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    boardToSolve.meltAll();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: focusNode,
      onKeyEvent: (KeyEvent keyEvent) {
        setState(() {
          if (keyEvent is KeyDownEvent) {
            String? char = keyEvent.character;
            if (char != null && numList.contains(char)) {
              int inputNumber = int.parse(char, radix: 10);
              if (pageIndex == 0) {
                if (notesMode) {
                  if (board.inFinalMode(activeCellID)) {
                    board.setNotesMode(activeCellID);
                  }
                  board.setNumber(activeCellID, inputNumber);
                } else {
                  if (board.inNotesMode(activeCellID)) {
                    board.unsetNotesMode(activeCellID);
                  }
                  board.setNumber(activeCellID, inputNumber);
                }
                if (board.isCompletelyCorrect()) {
                  board.freezeAll();
                  completed = true;
                }
              } else {
                if (solveInputEnabled) {
                  boardToSolve.setNumber(activeCellIDSolve, inputNumber);
                }
              }
            } else if (keyEvent.logicalKey == LogicalKeyboardKey.controlLeft) {
              notesMode = !notesMode;
            }
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 4,
          leading: const Icon(Icons.sports_esports),
          shadowColor: Colors.black,
          title: const Text(
            "SuDoKu",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: "SuDoKu",
                  applicationVersion: "1.0.0",
                  applicationIcon: Icon(Icons.sports_esports),
                  children: [
                    Center(child: Text("Created by Debasish Bordoloi")),
                    SizedBox.fromSize(size: Size.square(40)),
                    OutlinedButton(
                      onPressed: () => launchUrl(sourceUri),
                      child: Text("View Source"),
                    ),
                  ],
                );
              },
              icon: Icon(Icons.info_outline),
            ),
          ],
        ),
        body: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The Timer
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              "${timeElapsed ~/ 3600 < 10 ? "0${timeElapsed ~/ 3600}" : timeElapsed ~/ 3600}:${(timeElapsed % 3600) ~/ 60 < 10 ? "0${(timeElapsed % 3600) ~/ 60}" : (timeElapsed % 3600) ~/ 60}:${timeElapsed % 60 < 10 ? "0${timeElapsed % 60}" : timeElapsed % 60}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 72,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // The Controls
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Difficulty Selector
                            SegmentedButton(
                              selected: {difficultySelected},
                              onSelectionChanged: (Set<Difficulty> theSet) {
                                setState(() {
                                  difficultySelected = theSet.first;
                                });
                              },
                              multiSelectionEnabled: false,
                              segments: const [
                                ButtonSegment<Difficulty>(
                                  value: Difficulty.easy,
                                  label: Text("Easy"),
                                ),
                                ButtonSegment<Difficulty>(
                                  value: Difficulty.medium,
                                  label: Text("Medium"),
                                ),
                                ButtonSegment<Difficulty>(
                                  value: Difficulty.hard,
                                  label: Text("Hard"),
                                ),
                              ],
                            ),

                            // The Generate Puzzle Button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                              child: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    if (difficultySelected == Difficulty.easy) {
                                      board.generatePuzzle(30);
                                      generatedDifficulty = Difficulty.easy;
                                    } else if (difficultySelected == Difficulty.medium) {
                                      board.generatePuzzle(40);
                                      generatedDifficulty = Difficulty.medium;
                                    } else {
                                      board.generatePuzzle(50);
                                      generatedDifficulty = Difficulty.hard;
                                    }
                                    timeElapsed = 0;
                                  });
                                  completed = false;
                                  timerPaused = false;
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: const Center(child: Text("Generate Puzzle")),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // The Board View
              Expanded(
                flex: 5,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                  child: Center(
                    child: Container(
                      color: Colors.black45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: List<Row>.generate(
                          9,
                          (int indexC) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              children: List<Container>.generate(
                                9,
                                (indexR) {
                                  int currCellID = indexC * 9 + indexR + 1;
                                  int currNumber = board.getNumber(currCellID);
                                  Widget? cellWidget;
                                  List<int> notedNumbers = board.getNotedNumbers(currCellID);
                                  if (board.inNotesMode(currCellID)) {
                                    cellWidget = Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List<Row>.generate(
                                        3,
                                        (int indexNC) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: List<Center>.generate(
                                              3,
                                              (int indexNR) {
                                                return Center(
                                                  child: Text(
                                                    (notedNumbers.contains(indexNC * 3 + indexNR + 1)) ? (indexNC * 3 + indexNR + 1).toString() : " ",
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    cellWidget = Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          (currNumber == -1 || currNumber == 0) ? " " : currNumber.toString(),
                                          style: TextStyle(
                                            fontSize: 36,
                                            color: (board.isFrozen(currCellID)) ? Colors.black : Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(
                                      (indexR == 0) ? 2 : 1,
                                      (indexC == 0) ? 2 : 1,
                                      (indexR == 8) ? 2 : 1,
                                      (indexC == 8) ? 2 : 1,
                                    ),
                                    color: (activeCellID == currCellID)
                                        ? Colors.blue.shade100
                                        : ((shadedCellIDs.contains(currCellID)) ? Colors.blueGrey.shade50 : Colors.white),
                                    height: (MediaQuery.of(context).size.width * 5 / 8 < MediaQuery.of(context).size.height * 0.8)
                                        ? MediaQuery.of(context).size.width / 16
                                        : MediaQuery.of(context).size.height * 2 / 25,
                                    width: (MediaQuery.of(context).size.width * 5 / 8 < MediaQuery.of(context).size.height * 0.8)
                                        ? MediaQuery.of(context).size.width / 16
                                        : MediaQuery.of(context).size.height * 2 / 25,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: FittedBox(child: cellWidget),
                                      onPressed: () {
                                        setState(() {
                                          activeCellID = currCellID;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        child: FilledButton(
                          onPressed: (boardToSolve.isBoardEmpty())
                              ? null
                              : () {
                                  for (int id = 1; id <= 81; id++) {
                                    if (boardToSolve.isFrozen(id)) {
                                      boardToSolve.melt(id);
                                      boardToSolve.setNumber(id, 0);
                                    }
                                  }
                                  if (boardToSolve.isImpossible()) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext cc) => AlertDialog(
                                        icon: const Icon(Icons.error),
                                        title: const Text("Impossible to Solve"),
                                        content: const Text("The current set of clues have no possible solution."),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(cc).pop(),
                                            child: const Text("Ok"),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      for (int id = 1; id <= 81; id++) {
                                        if (boardToSolve.getNumber(id) == 0) {
                                          boardToSolve.freeze(id);
                                        }
                                      }
                                      boardToSolve.solve();
                                      solveInputEnabled = false;
                                      boardSolved = true;
                                    });
                                  }
                                },
                          child: Container(
                            width: double.infinity,
                            child: const Center(child: Text("Solve")),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                        child: OutlinedButton(
                          onPressed: (!boardSolved)
                              ? null
                              : () {
                                  setState(() {
                                    for (int id = 1; id <= 81; id++) {
                                      if (boardToSolve.isFrozen(id)) {
                                        boardToSolve.melt(id);
                                        boardToSolve.setNumber(id, 0);
                                      }
                                    }
                                    solveInputEnabled = true;
                                    boardSolved = false;
                                  });
                                },
                          child: Container(
                            width: double.infinity,
                            child: const Center(child: Text("Un-solve")),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              boardToSolve.meltAll();
                              boardToSolve.clear();
                              solveInputEnabled = true;
                              boardSolved = false;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            child: const Center(child: Text("Reset")),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                  child: Center(
                    child: Container(
                      color: Colors.black45,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Row>.generate(
                          9,
                          (int indexC) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Container>.generate(
                              9,
                              (int indexR) {
                                int currCellID = indexC * 9 + indexR + 1;
                                int currNumber = boardToSolve.getNumber(currCellID);
                                return Container(
                                  margin: EdgeInsets.fromLTRB(
                                    (indexR == 0) ? 2 : 1,
                                    (indexC == 0) ? 2 : 1,
                                    (indexR == 8) ? 2 : 1,
                                    (indexC == 8) ? 2 : 1,
                                  ),
                                  color: (activeCellIDSolve == currCellID && solveInputEnabled)
                                      ? Colors.blue.shade100
                                      : ((shadedCellIDs.contains(currCellID)) ? Colors.blueGrey.shade50 : Colors.white),
                                  height: (MediaQuery.of(context).size.width * 5 / 8 < MediaQuery.of(context).size.height * 0.8)
                                      ? MediaQuery.of(context).size.width / 16
                                      : MediaQuery.of(context).size.height * 2 / 25,
                                  width: (MediaQuery.of(context).size.width * 5 / 8 < MediaQuery.of(context).size.height * 0.8)
                                      ? MediaQuery.of(context).size.width / 16
                                      : MediaQuery.of(context).size.height * 2 / 25,
                                  child: TextButton(
                                    onPressed: (solveInputEnabled)
                                        ? () {
                                            setState(() {
                                              activeCellIDSolve = currCellID;
                                            });
                                          }
                                        : null,
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          (currNumber == -1 || currNumber == 0) ? " " : currNumber.toString(),
                                          style: TextStyle(
                                            fontSize: 36,
                                            color: boardToSolve.isFrozen(currCellID) ? Colors.blue : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ][pageIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: updatePageIndex,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.sports_esports),
              icon: Icon(Icons.sports_esports_outlined),
              label: "Play",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.functions),
              icon: Icon(Icons.functions_outlined),
              label: "Solve",
            ),
          ],
        ),
        floatingActionButton: (pageIndex == 1)
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Note button
                  FloatingActionButton(
                    backgroundColor: (notesMode) ? Colors.blue.shade900 : Colors.blue.shade100,
                    onPressed: () {
                      setState(() {
                        notesMode = true;
                      });
                    },
                    child: Icon(
                      Icons.edit_note,
                      color: (notesMode) ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox.fromSize(size: const Size.square(30)),
                  // Final button
                  FloatingActionButton(
                    backgroundColor: (!notesMode) ? Colors.blue.shade900 : Colors.blue.shade100,
                    onPressed: () {
                      setState(() {
                        notesMode = false;
                      });
                    },
                    child: Icon(
                      Icons.edit,
                      color: (!notesMode) ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
