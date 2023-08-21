# Sudoku solver

An OCaml project that solves a given standard 9*9 sudoku. This project was a homework problem for students enrolled in Programiranje 1 at Faculty of Mathematics and Physics in Ljubljana in the year 2022/2023.

Even though I was never enrolled in this course I have decided to try and complete this problem by myself.

# Usage

There is a `sudoku.exe` file, which can be used to solve a given sudoku. By running the command

    ./sudoku.exe example-sudoku.sdk

the program will solve the sudoku given in the `example-sudoku.sdk` file. In the directory `sudokuji` there are test cases that can be used to solve with this program. If you want to solve a custom sudoku make .sdk file using the same pattern as in test cases.

At the time of doing this project I had nothing better to do, so I also build a simple app for a more user friendly experience in Java. In the `Java App/FINAL_APP` there is a `Sudoku_solver.jar` file of this app and another copy of `sudoku.exe` file. In order to run .jar file and use it to solve custom sudokus, both of these files must be in the same directory.

I have to mention that there is plenty of room for improvement for the app. Some of the issues: If no solution for the given sudoku exist nothing will happen, the overall UI could be improved, the algorithm for finding the solution should be improved as it can sometimes be quite time consuming (so I set the max time for solving it to 3 seconds for now), ...

Also in order for everything to work there must be OCaml and Java installed.
