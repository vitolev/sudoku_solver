import javax.swing.*;
import java.awt.*;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

public class MainPanel extends JPanel implements MouseListener, KeyListener {

    public MainPanel() {
        setBackground(new Color(229, 229, 229));
        this.addMouseListener(this);
        this.addKeyListener(this);
        setFocusable(true);
    }

    @Override
    public Dimension getPreferredSize() {
        return new Dimension(500, 500);
    }


    private final static double LINE_WIDTH = 0.04;
    private final static double THICK_LINE_WIDTH = 0.08;

    private double squareWidth() {
        return Math.min(getWidth(), getHeight()) / 10;
    }

    private final static double PADDING = 0.18;

    private void paintNumber(Graphics2D g2, int number, int i, int j) {
        double w = squareWidth();
        g2.setFont(new Font(Font.MONOSPACED, Font.PLAIN, (int) (w * 0.9)));
        double x = w * (i + 0.53 + 0.5 * LINE_WIDTH + PADDING);
        double y = w * (j + 1.1 + 0.5 * LINE_WIDTH + PADDING);
        g2.drawString(String.valueOf(number), (int)x, (int)y);
    }

    private void highlightActiveCell(Graphics2D g2){
        if(Main.x != -1 & Main.y != -1){
            double w = squareWidth();
            g2.setStroke(new BasicStroke((float) (1.5 * w * THICK_LINE_WIDTH)));
            g2.setColor(new Color(159, 159, 159));
            g2.drawRect((int)((Main.x + 0.5) * w), (int)((Main.y + 0.5) * w), (int)w, (int)w);
        }
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2 = (Graphics2D) g;
        double w = squareWidth();
        // lines
        g2.setColor(new Color(59, 59, 59));
        for (int i = 0; i < 10; i++) {
            if (i % 3 == 0){
                g2.setStroke(new BasicStroke((float) (w * THICK_LINE_WIDTH)));
            }
            else{
                g2.setStroke(new BasicStroke((float) (w * LINE_WIDTH)));
            }
            g2.drawLine((int) (i * w + w / 2),
                    (int) (w / 2),
                    (int) (i * w + w / 2),
                    (int) (10 * w - w / 2));
            g2.drawLine((int) (w / 2),
                    (int) (i * w + w / 2),
                    (int) (10 * w - w / 2),
                    (int) (i * w + w / 2));
        }

        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                int number = Main.grid[i][j];
                if (number != 0){
                    paintNumber(g2, number, i, j);
                }
            }
        }

        highlightActiveCell(g2);
    }

    @Override
    public void mouseClicked(MouseEvent e) {
        int w = (int)(squareWidth());
        int x = e.getX() - w / 2;
        int y = e.getY() - w / 2;
        int i = x / w ;
        double di = (x % w) / squareWidth() ;
        int j = y / w ;
        double dj = (y % w) / squareWidth() ;
        if (0 <= i && i < 9 &&
                0.5 * LINE_WIDTH < di && di < 1.0 - 0.5 * LINE_WIDTH &&
                0 <= j && j < 9 &&
                0.5 * LINE_WIDTH < dj && dj < 1.0 - 0.5 * LINE_WIDTH) {
            Main.x = i;
            Main.y = j;
        }
        repaint();
    }

    @Override
    public void mousePressed(MouseEvent e) {

    }

    @Override
    public void mouseReleased(MouseEvent e) {

    }

    @Override
    public void mouseEntered(MouseEvent e) {

    }

    @Override
    public void mouseExited(MouseEvent e) {

    }

    @Override
    public void keyTyped(KeyEvent e) {

    }

    private Character[] digits = new Character[]{
            '1','2','3','4','5','6','7','8','9'
    };
    @Override
    public void keyPressed(KeyEvent e) {
        for (char ch : digits){
            if(e.getKeyChar() == ch){
                Main.setDigitInGrid(Integer.parseInt(String.valueOf(ch)));
                break;
            }
        }
        if(e.getKeyCode() == KeyEvent.VK_BACK_SPACE){
            Main.setDigitInGrid(0);
        }
        repaint();
    }

    @Override
    public void keyReleased(KeyEvent e) {

    }
}
