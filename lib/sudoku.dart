import 'graph.dart';
import 'dart:math';

// Class for each cell in the sudoku board.
// Can either hold a single number
// Or multiple numbers (in case of notes)
class SudokuCell {
  late int id;
  bool notes = false; // Whether cell is being used for notes
  List<int> numbers = []; // empty list means cell is empty
  // If cell is used for final numberings, the first number will represent the number of the cell

  SudokuCell(this.id);

  // Check if in notes mode:
  bool notesEnabled() {
    return notes;
  }

  // Check if in final mode:
  bool inFinalMode() {
    return !notes;
  }

  // Used to set the notes mode in the cell
  void setNotesMode() {
    if (!notes) {
      notes = true;
      numbers.clear();
    }
  }

  // Used to set the final numbering mode in the cell
  void unsetNotesMode() {
    if (notes) {
      notes = false;
      numbers.clear();
    }
  }

  // Used to add a number in case of both notes and final modes
  // In case of notes, if number is already added, then it is removed.
  // In case of final, the present number is overwritten.
  void setNumber(int number) {
    if (number > 0 && number <= 9) {
      if (notes) {
        if (numbers.contains(number)) {
          numbers.remove(number);
        } else {
          numbers.add(number);
        }
      } else {
        if (numbers.isEmpty) {
          numbers.add(number);
        } else {
          numbers[0] = number;
        }
      }
    } else if (number == 0) {
      numbers.clear();
    }
  }

  // Totally clear the cell, irrespective of its mode
  void clear() {
    numbers.clear();
  }

  // Retrieve the number in the cell
  // If cell is empty, return 0
  // If cell is in notes mode, return -1
  int getNumber() {
    if (notes) {
      return -1;
    } else if (numbers.isEmpty) {
      return 0;
    } else {
      return numbers[0];
    }
  }

  // == operator & hashCode (?) overload
  @override
  bool operator ==(covariant SudokuCell other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode ^ notes.hashCode ^ numbers.hashCode;

  // Temp string conversion for debugging
  // TO BE REMOVED
  @override
  String toString() {
    return "$id";
  }
}

// Class for representing the Sudoku Board
class SudokuBoard extends Graph<SudokuCell, bool> {
  bool foundOneSolution = false;
  Random randomGenerator = Random();
  List<bool> frozen = List<bool>.generate(81, (int index) => true);

  // Construction of the format of a 9x9 sudoku board
  SudokuBoard() {
    // Inserting 81 cells
    for (int i = 1; i <= 81; i++) {
      insertVertex(SudokuCell(i));
    }

    // Inserting edges for row-wise, and column-wise adjacencies of the 81 cells
    for (int i = 1; i <= 81; i++) {
      int rowStartId = (i % 9 == 0) ? ((i ~/ 9) - 1) * 9 + 1 : (i ~/ 9) * 9 + 1;
      int rowEndId = rowStartId + 8;
      int columnStartId = (i % 9 == 0) ? 9 : i % 9;
      int columnEndId = columnStartId + 72;
      for (int j = rowStartId; j <= rowEndId; j++) {
        if (i != j) {
          insertEdge(SudokuCell(i), SudokuCell(j), true);
        }
      }
      for (int j = columnStartId; j <= columnEndId; j += 9) {
        if (i != j) {
          insertEdge(SudokuCell(i), SudokuCell(j), true);
        }
      }
    }

    // Inserting edges for the adjacencies in the 3x3 squares
    List<List<int>> boxes = [
      [1, 2, 3, 10, 11, 12, 19, 20, 21],
      [4, 5, 6, 13, 14, 15, 22, 23, 24],
      [7, 8, 9, 16, 17, 18, 25, 26, 27],
      [28, 29, 30, 37, 38, 39, 46, 47, 48],
      [31, 32, 33, 40, 41, 42, 49, 50, 51],
      [34, 35, 36, 43, 44, 45, 52, 53, 54],
      [55, 56, 57, 64, 65, 66, 73, 74, 75],
      [58, 59, 60, 67, 68, 69, 76, 77, 78],
      [61, 62, 63, 70, 71, 72, 79, 80, 81],
    ];
    for (int i = 1; i <= 81; i++) {
      for (List<int> j in boxes) {
        if (j.contains(i)) {
          for (int k in j) {
            if (k != i) {
              insertEdge(SudokuCell(i), SudokuCell(k), true);
            }
          }
        }
      }
    }
  }

  // Sets the frozen status of all SudokuCells to false
  void meltAll() {
    for (int i = 0; i < 81; i++) {
      frozen[i] = false;
    }
  }

  // Sets a Sudoku cell with given cell ID to frozen status
  void freeze(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      frozen[cellID - 1] = true;
    }
  }

  // Sets all Sudoku cells to frozen status
  void freezeAll() {
    for (int i = 0; i < 81; i++) {
      frozen[i] = true;
    }
  }

  // Sets Sudoku cell with given ID to molten status (not frozen)
  void melt(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      frozen[cellID - 1] = false;
    }
  }

  // Checks if a cell is frozen or not
  bool isFrozen(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      return frozen[cellID - 1];
    } else {
      return false;
    }
  }

  // Wrapper to call SudokuCell.getNumber()
  int getNumber(int cellID) {
    if (cellID <= 0 || cellID > 81) {
      return -1;
    }
    return vertexList[cellID - 1].getNumber();
  }

  // Wrapper to call SudokuCell.setNumber()
  void setNumber(int cellID, int number) {
    if (cellID > 0 && cellID <= 81) {
      if (!isFrozen(cellID)) {
        vertexList[cellID - 1].setNumber(number);
      }
    }
  }

  // Checks if the board has no user inputs
  bool isBoardEmpty() {
    for (int i = 0; i < 81; i++) {
      if (vertexList[i].numbers.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  // Checks if the board is impossible to solve with current final values in the cells.
  bool isImpossible() {
    for (SudokuCell cell in vertexList) {
      if (cell.getNumber() != 0 && cell.getNumber() != -1) {
        for (SudokuCell neighbour in getNeighbours(cell)) {
          if (cell.getNumber() == neighbour.getNumber()) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Wrapper to call SudokuCell.setNotesMode()
  void setNotesMode(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      vertexList[cellID - 1].setNotesMode();
    }
  }

  // Wrapper to call SudokuCell.unsetNotesMode()
  void unsetNotesMode(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      vertexList[cellID - 1].unsetNotesMode();
    }
  }

  // Wrapper to call SudokuCell.inFinalMode()
  bool inFinalMode(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      return vertexList[cellID - 1].inFinalMode();
    } else {
      return false;
    }
  }

  // Wrapper to call SudokuCell.notesEnables()
  bool inNotesMode(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      return vertexList[cellID - 1].notesEnabled();
    } else {
      return false;
    }
  }

  // Returns the numbers noted in a cell, if cell has Notes mode on. Else returns an empty list
  List<int> getNotedNumbers(int cellID) {
    if (cellID > 0 && cellID <= 81) {
      if (vertexList[cellID - 1].notesEnabled()) {
        return List<int>.from(vertexList[cellID - 1].numbers);
      }
    }
    return [];
  }

  // Clear the whole Sudoku Board
  void clear() {
    for (SudokuCell cell in vertexList) {
      cell.unsetNotesMode();
      cell.clear();
    }
  }

  // conversion to String
  // used for printing
  @override
  String toString() {
    String result = "";
    int temp = 0;
    for (int i = 0; i < 81; i += 9) {
      for (int j = 0; j < 9; j++) {
        if (vertexList[i + j].notesEnabled() || (temp = vertexList[i + j].getNumber()) == 0) {
          result += "X ";
        } else {
          result += "$temp ";
        }
      }
      result += "\n";
    }
    return result;
  }

  // Solver for the board, irrespective of number of filled cells
  // Returns false if current board is not solvable without changing any prefilled cells, else true.
  // Clears all cells in note mode.
  // Generates a random solution, if multiple solutions are possible.
  bool solve() {
    for (SudokuCell cell in vertexList) {
      cell.unsetNotesMode();
    }
    return solveRecursively();
  }

  // Recursive function used by solver function above
  bool solveRecursively() {
    int emptyCellIndex = -1;
    for (int i = 0; i < 81; i++) {
      if (vertexList[i].getNumber() == 0) {
        emptyCellIndex = i;
        break;
      }
    }
    if (emptyCellIndex == -1) {
      return true;
    }
    List<int> possibilities = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    for (SudokuCell cell in getNeighbours(vertexList[emptyCellIndex])) {
      int temp = cell.getNumber();
      if (possibilities.contains(temp)) {
        possibilities.remove(temp);
      }
    }
    while (possibilities.isNotEmpty) {
      int randomNumber = randomGenerator.nextInt(possibilities.length);
      vertexList[emptyCellIndex].setNumber(possibilities[randomNumber]);
      possibilities.removeAt(randomNumber);
      if (solveRecursively()) {
        return true;
      }
    }
    vertexList[emptyCellIndex].setNumber(0);
    return false;
  }

  // Set board from input
  int setCells(List<int> numbersList) {
    if (numbersList.length != 81) {
      return -1;
    } else {
      for (int number in numbersList) {
        if (number < 0 || number > 9) {
          return -2;
        }
      }
      int i = 0;
      for (SudokuCell cell in vertexList) {
        cell.unsetNotesMode();
        cell.setNumber(numbersList[i]);
        i++;
      }
      return 0;
    }
  }

  // To check if the board has unique solution
  // Will destroy all notes, but the empty cells will remain empty
  bool hasUniqueSolution() {
    foundOneSolution = false;
    for (SudokuCell cell in vertexList) {
      cell.unsetNotesMode();
    }
    return !solveForMultipleSolution();
  }

  // Recursive function for use in the above function
  bool solveForMultipleSolution() {
    SudokuCell? emptyCell;
    int temp = 0;
    for (SudokuCell cell in vertexList) {
      if (cell.getNumber() == 0) {
        emptyCell = cell;
      }
    }
    if (emptyCell == null) {
      if (!foundOneSolution) {
        foundOneSolution = true;
        return false;
      } else {
        return true;
      }
    }
    List<bool> possibilities = List<bool>.generate(9, (index) => true);
    for (SudokuCell neighbour in getNeighbours(emptyCell)) {
      temp = neighbour.getNumber();
      if (temp != 0) {
        possibilities[temp - 1] = false;
      }
    }
    for (int i = 0; i < 9; i++) {
      if (possibilities[i]) {
        emptyCell.setNumber(i + 1);
        if (solveForMultipleSolution()) {
          emptyCell.setNumber(0);
          return true;
        }
      }
    }
    emptyCell.setNumber(0);
    return false;
  }

  // To generate a puzzle with a certain number of empty cells.
  // if numEmptyCells is more than 64, it will only hide 64 cells, as required by any sudoku board to have unique solution.
  void generatePuzzle(int numEmptyCells) {
    meltAll();
    if (numEmptyCells > 64) {
      numEmptyCells = 64;
    }
    if (numEmptyCells < 0) {
      numEmptyCells = 0;
    }
    for (SudokuCell cell in vertexList) {
      cell.unsetNotesMode();
      cell.setNumber(0);
    }
    solve();
    List<int> hideLocations = List<int>.generate(81, (index) => index);
    int toHideIndex = 0, currValue = 0;
    while (numEmptyCells > 0 && hideLocations.isNotEmpty) {
      toHideIndex = hideLocations[randomGenerator.nextInt(hideLocations.length)];
      currValue = vertexList[toHideIndex].getNumber();
      vertexList[toHideIndex].setNumber(0);
      if (hasUniqueSolution()) {
        numEmptyCells--;
      } else {
        vertexList[toHideIndex].setNumber(currValue);
      }
      hideLocations.remove(toHideIndex);
    }
    for (int i = 0; i < 81; i++) {
      if (vertexList[i].getNumber() != 0) {
        freeze(i + 1);
      }
    }
  }

  // Is the puzzle complete and correct?
  bool isCompletelyCorrect() {
    for (SudokuCell currCell in vertexList) {
      if (currCell.notesEnabled() || currCell.getNumber() == 0) {
        return false;
      }
      for (SudokuCell neighbour in getNeighbours(currCell)) {
        if (neighbour.getNumber() == currCell.getNumber()) {
          return false;
        }
      }
    }
    return true;
  }
}

// bool solveRecursively() {
//   int emptyCellIndex = -1;
//   for (int i = 0; i < 81; i++) {
//     if (vertexList[i].getNumber() == 0) {
//       emptyCellIndex = i;
//       break;
//     }
//   }
//   if (emptyCellIndex == -1) {
//     return true;
//   }
//   List<bool> poss = List<bool>.generate(9, (index) => true);
//   for (SudokuCell cell in getNeighbours(vertexList[emptyCellIndex])) {
//     int temp = cell.getNumber();
//     if (temp != 0) {
//       poss[temp - 1] = false;
//     }
//   }
//   for (int i = 0; i < 9; i++) {
//     if (poss[i]) {
//       vertexList[emptyCellIndex].setNumber(i + 1);
//       if (solveRecursively()) {
//         return true;
//       }
//     }
//   }
//   vertexList[emptyCellIndex].setNumber(0);
//   return false;
// }
