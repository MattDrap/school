package bia.rnn;

import pacman.controllers.Controller;
import pacman.controllers.examples.RandomGhosts;
import pacman.game.Constants;
import pacman.game.Game;
import pacman.game.GameView;

import java.util.EnumMap;
import java.util.Random;

import static pacman.game.Constants.DELAY;

/**
 * Created by drchajan on 21/03/14.
 */
public class PacManPlayer {

    public static void main(String[] args) {
        PacManRNNController pacManController = PacManRNNController.load("rnn.dat");
        Controller<EnumMap<Constants.GHOST, Constants.MOVE>> ghostController = new RandomGhosts();

        int trials = 10;
        double avgScore = 0;

        Random rnd = new Random(0);
        Game game;

        for (int i = 0; i < trials; i++) {
            game = new Game(rnd.nextLong());
            GameView gv = new GameView(game).showGame();

            while (!game.gameOver()) {
                try {
                    Thread.sleep(DELAY);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                game.advanceGame(pacManController.getMove(game.copy(), System.currentTimeMillis() + DELAY),
                        ghostController.getMove(game.copy(), System.currentTimeMillis() + DELAY));
                gv.repaint();
            }

            avgScore += game.getScore();
            System.out.println(i + "\t" + game.getScore());
        }
        avgScore /= trials;
        System.out.println("Average: " + avgScore);
    }
}
