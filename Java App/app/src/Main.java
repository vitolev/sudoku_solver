import java.io.*;
import java.util.concurrent.TimeUnit;

public class Main {
    public static void main(String[] args) {
        for(int i = 0; i < 9; i++){
            grid[i][i] = i;
        }
        grid[4][0] = 3;
        grid[1][8] = 7;
        MainFrame frame = new MainFrame();
        frame.pack();
        frame.setVisible(true);
    }

    public static int[][] grid = new int[9][9];
    public static int x = -1;
    public static int y = -1;

    public static void clearGrid(){
        grid = new int[9][9];
    }

    public static String solveSudoku() {
        try{
            String ocamlProgramPath = System.getProperty("user.dir") + "/sudoku.exe";
            String sudokuPath = System.getProperty("user.dir") + "/temp.sdk";

            BufferedWriter out = new BufferedWriter
                    (new OutputStreamWriter(new FileOutputStream(sudokuPath, true),"UTF-8"));
            out.write(makeStringRepresentation());
            out.close();

            System.out.println("Attempting to solve sudoku...");
            Process process = new ProcessBuilder(ocamlProgramPath, sudokuPath).start();

            if(!process.waitFor(3000, TimeUnit.MILLISECONDS)) {
                //timeout - kill the process.
                process.destroy(); // consider using destroyForcibly instead
                return "Timeout";
            }
            else {
                InputStream processInputStream = process.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(processInputStream));
                String output = readAllLines(reader);
                System.out.println("Output: " + output);
                return output;
            }
        }
        catch (Exception e){
            e.printStackTrace();
            return "Error";
        }
    }

    public static void setDigitInGrid(int digit){
        if(x != -1 & y != -1){
            grid[x][y] = digit;
        }
    }

    public static void setDigitInGridCoords(int digit, int x, int y){
        grid[x][y] = digit;
    }

    private static String makeStringRepresentation(){
        String sudoku = "┏━━━┯━━━┯━━━┓\n";
        for(int i = 0; i < 9; i++){
            sudoku += "┃";
            for (int j = 0; j < 9; j++){
                int value = grid[j][i];
                if(value != 0){
                    sudoku += String.valueOf(value);
                }
                else{
                    sudoku += " ";
                }

                if(j == 2 | j == 5){
                    sudoku += "│";
                }
            }
            sudoku += "┃\n";

            if(i == 2 | i == 5){
                sudoku += "┠───┼───┼───┨\n";
            }
        }
        sudoku += "┗━━━┷━━━┷━━━┛\n";
        return sudoku;
    }

    private static String readAllLines(BufferedReader reader) throws IOException {
        StringBuilder content = new StringBuilder();
        String line;

        while ((line = reader.readLine()) != null) {
            content.append(line);
            content.append(System.lineSeparator());
        }

        return content.toString();
    }
}