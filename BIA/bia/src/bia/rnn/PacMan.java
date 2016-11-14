package bia.rnn;

import bia.common.Utils;
import bia.sga.ContinuousFunction;
import bia.sga.SGA;
import pacman.controllers.Controller;
import pacman.controllers.examples.RandomGhosts;
import pacman.controllers.examples.RandomPacMan;
import pacman.game.Constants;
import pacman.game.Game;

import java.util.EnumMap;
import java.util.Random;

import static pacman.game.Constants.DELAY;

/**
 * Created by drchajan on 18/03/14.
 */
public class PacMan implements ContinuousFunction {
    private final PacManRNNController pacManController = new PacManRNNController();
    private final Controller<EnumMap<Constants.GHOST, Constants.MOVE>> ghostController = new RandomGhosts();

    @Override
    public double f(double[] x) {

        pacManController.setWeights(x);

        int trials = 10;
        double avgScore = 0;

        Random rnd = new Random(0);
        Game game;

        for (int i = 0; i < trials; i++) {
            game = new Game(rnd.nextLong());

            pacManController.reinitializeRNN();

            while (!game.gameOver()) {
                game.advanceGame(pacManController.getMove(game.copy(), System.currentTimeMillis() + DELAY),
                        ghostController.getMove(game.copy(), System.currentTimeMillis() + DELAY));
            }

            avgScore += game.getScore();
//            System.out.println(i + "\t" + game.getScore());
        }

        return avgScore / trials;
    }

    @Override
    public int getDimension() {
        return pacManController.getNumWeights();
    }

    @Override
    public void store(double[] x) {
        pacManController.store("rnn.dat");
    }

    public static void main(String[] args) throws Exception {
        double[] best = SGA.run();
        System.out.println("RNN weights: " + Utils.vectorToString(best));
    }
}
