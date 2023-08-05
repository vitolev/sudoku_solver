import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MainFrame extends JFrame implements ActionListener {

    private MainPanel panel;

    private JButton clear;
    private JButton solve;

    public MainFrame() {
        this.setTitle("Sudoku solver");
        this.setDefaultCloseOperation(EXIT_ON_CLOSE);

        // menu
        JMenuBar menu_bar = new JMenuBar();
        menu_bar.setPreferredSize(new Dimension(500, 30));
        this.setJMenuBar(menu_bar);

        // Create a focus traversal policy that ignores the buttons
        FocusTraversalPolicy traversalPolicy = new FocusTraversalPolicy() {
            @Override
            public Component getDefaultComponent(Container focusCycleRoot) {
                return panel; // Set the default focus to your MainPanel
            }

            @Override
            public Component getComponentAfter(Container focusCycleRoot, Component aComponent) {
                return panel; // Ensure focus moves to MainPanel after aComponent
            }

            @Override
            public Component getComponentBefore(Container focusCycleRoot, Component aComponent) {
                return panel; // Ensure focus moves to MainPanel before aComponent
            }

            @Override
            public Component getFirstComponent(Container focusCycleRoot) {
                return panel; // Set the first focusable component to MainPanel
            }

            @Override
            public Component getLastComponent(Container focusCycleRoot) {
                return panel; // Set the last focusable component to MainPanel
            }
        };

        this.setFocusTraversalPolicy(traversalPolicy);

        menu_bar.add(Box.createHorizontalGlue());

        clear = new JButton("Clear");
        menu_bar.add(clear);
        clear.addActionListener(this);

        menu_bar.add(Box.createHorizontalGlue());

        solve = new JButton("Solve");
        menu_bar.add(solve);
        solve.addActionListener(this);

        menu_bar.add(Box.createHorizontalGlue());

        panel = new MainPanel();
        getContentPane().add(panel);
        panel.requestFocusInWindow();
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        if (e.getSource() == clear){
            Main.clearGrid();
        } else if (e.getSource() == solve) {
            String output = Main.solveSudoku();
            File myObj = new File(System.getProperty("user.dir") + "/temp.sdk");
            myObj.delete();
            if(output.equals("Error") | output.equals("Timeout")){

            }
            else{
                extractSolution(output);
            }
        }
        panel.repaint();
        panel.requestFocusInWindow();
    }

    private void extractSolution(String solution){
        // Define the regular expression pattern to match the desired part
        Pattern pattern = Pattern.compile("┏━━━.*?┛", Pattern.DOTALL);
        Matcher matcher = pattern.matcher(solution);

        if(matcher.find()){
            if (matcher.find()) {
                String extractedPart = flattenSolution(matcher.group());
                updateGridWithSolution(extractedPart);
            } else {
                // No solution exists
            }
        }
        else{
            // Error
        }
    }

    private String flattenSolution(String solution){
        solution = solution.replaceAll("[^\\d]", "");
        return solution;
    }

    private void updateGridWithSolution(String solution){
        for(int i = 0; i < 9; i++){
            for(int j = 0; j < 9; j++){
                Main.setDigitInGridCoords(Integer.parseInt(String.valueOf(solution.charAt(i*9+j))), j, i);
            }
        }
    }
}
