package bia.rnn;

import pacman.controllers.Controller;
import pacman.game.Constants;
import pacman.game.Constants.MOVE;
import pacman.game.Game;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/*
 * The Class RandomPacMan.
 */
public final class PacManRNNController extends Controller<MOVE> {

    private final RNN rnn;

    public PacManRNNController(RNN rnn) {
        this.rnn = rnn;
    }

    public PacManRNNController() {
        this(new RNN(9, 2, MOVE.values().length));
    }

    public void reinitializeRNN() {
        rnn.resetActivities();
    }

    public void setWeights(double[] w) {
        rnn.setWeights(w);
    }

    public int getNumWeights() {
        return rnn.getNumWeights();
    }

    public MOVE getMove(Game game, long timeDue) {
        rnn.loadInputs(extractInputs(game));
        rnn.propagate();
        return MOVE.values()[rnn.getClassification()];
    }

    private double[] extractInputs(Game game) {
        double[] x = new double[rnn.getNumInputs()];

        //PacMan position
        int myIdx = game.getPacmanCurrentNodeIndex();

        //direction and distance towards closest pill
        int closestPillIdx = game.getClosestNodeIndexFromNodeIndex(myIdx, game.getActivePillsIndices(), Constants.DM.PATH);
        double[] pillDelta = getDeltas(game, closestPillIdx);

        //direction and distance towards closest power-pill
        int closestPowerPillIdx = game.getClosestNodeIndexFromNodeIndex(myIdx, game.getActivePowerPillsIndices(), Constants.DM.PATH);
        double[] powerPillDelta = getDeltas(game, closestPillIdx);

        //move possibilities
        Set<MOVE> possibleMoves = new HashSet<MOVE>(Arrays.asList(game.getPossibleMoves(myIdx)));
        double possibleUp = possibleMoves.contains(MOVE.UP) ? 1.0 : 0.0;
        double possibleDown = possibleMoves.contains(MOVE.DOWN) ? 1.0 : 0.0;
        double possibleLeft = possibleMoves.contains(MOVE.LEFT) ? 1.0 : 0.0;
        double possibleRight = possibleMoves.contains(MOVE.RIGHT) ? 1.0 : 0.0;

        int ghostBlinkyIdx = game.getGhostCurrentNodeIndex(Constants.GHOST.BLINKY);
        double[] ghostBlinkyDelta = getDeltas(game, ghostBlinkyIdx);

        int ghostInkyIdx = game.getGhostCurrentNodeIndex(Constants.GHOST.INKY);
        double[] ghostInkyDelta = getDeltas(game, ghostInkyIdx);

        int ghostPinkyIdx = game.getGhostCurrentNodeIndex(Constants.GHOST.PINKY);
        double[] ghostPinkyDelta = getDeltas(game, ghostPinkyIdx);

        int ghostSueIdx = game.getGhostCurrentNodeIndex(Constants.GHOST.SUE);
        double[] ghostSueDelta = getDeltas(game, ghostSueIdx);

        int cnt = 0;
        x[cnt++] = 1.0;//bias
        x[cnt++] = pillDelta[0];
        x[cnt++] = pillDelta[1];
        x[cnt++] = powerPillDelta[0];
        x[cnt++] = powerPillDelta[1];
        x[cnt++] = possibleUp;
        x[cnt++] = possibleDown;
        x[cnt++] = possibleLeft;
        x[cnt++] = possibleRight;
//        x[cnt++] = ghostBlinkyDelta[0];
//        x[cnt++] = ghostBlinkyDelta[1];
//        x[cnt++] = ghostInkyDelta[0];
//        x[cnt++] = ghostInkyDelta[1];
//        x[cnt++] = ghostPinkyDelta[0];
//        x[cnt++] = ghostPinkyDelta[1];
//        x[cnt++] = ghostSueDelta[0];
//        x[cnt++] = ghostSueDelta[1];

        return x;
    }

    private double[] getDeltas(Game game, int targetIdx) {
        if (targetIdx == -1) {
            return new double[]{0.0, 0.0};
        }
        int myIdx = game.getPacmanCurrentNodeIndex();
        return new double[]{
                game.getNodeXCood(myIdx) - game.getNodeXCood(targetIdx),
                game.getNodeYCood(myIdx) - game.getNodeYCood(targetIdx)
        };
    }

    public void store(String fileName) {
        rnn.serialize(fileName);
    }

    public static PacManRNNController load(String fileName) {
        return new PacManRNNController(RNN.deserialize(fileName));
    }
}