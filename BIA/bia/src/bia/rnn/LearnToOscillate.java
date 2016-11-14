package bia.rnn;

import bia.common.Utils;
import bia.sga.ContinuousFunction;
import bia.sga.SGA;

/**
 * Created by drchajan on 17/03/14.
 */
public class LearnToOscillate implements ContinuousFunction {
    private static final int SEQUENCE_LENGTH = 10;


    private RNN rnn;

    public LearnToOscillate() {
        this.rnn = new RNN(1, 2, 1);
    }

    public double[] targetSequence() {
        double[] s = new double[SEQUENCE_LENGTH];
        for (int i = 0; i < SEQUENCE_LENGTH; i++) {
            s[i] = i % 2;
//            s[i] = (i % 3)/2.0;
//            s[i] = 0.5 + Math.sin(i)/2.0;
        }
        return s;
    }

    public double evaluateForWeights(double[] w) {
        double[] s = targetSequence();
        rnn.setWeights(w);
        rnn.resetActivities();
        rnn.loadInputs(new double[]{1.0});

        double err = 0.0;
        for (int i = 0; i < SEQUENCE_LENGTH; i++) {
            rnn.propagate();//push data into the network
            double y = rnn.getOutputs()[0];//get the output
            double d = s[i];//desired output
            double e = y - d;
            err += e * e;
        }
        return err;
    }

    public double[] evaluateOutputsForWeights(double[] w) {
        double[] o = new double[SEQUENCE_LENGTH];

        rnn.setWeights(w);
        rnn.resetActivities();
        rnn.loadInputs(new double[]{1.0});

        for (int i = 0; i < SEQUENCE_LENGTH; i++) {
            rnn.propagate();//push data into the network
            double y = rnn.getOutputs()[0];//get the output
            o[i] = y;
        }
        return o;
    }

    @Override
    public double f(double[] x) {
        return -evaluateForWeights(x);
    }

    @Override
    public int getDimension() {
        return rnn.getNumWeights();
    }

    @Override
    public void store(double[] x) {
    }

    public static void main(String[] args) throws Exception {
        double[] best = SGA.run();
        LearnToOscillate learnToOscillate = new LearnToOscillate();

        System.out.println("RNN error: " + learnToOscillate.evaluateForWeights(best));
        System.out.println("RNN weights: " + Utils.vectorToString(best));
        System.out.println("Target sequence : (" + Utils.vectorToString(learnToOscillate.targetSequence()) + ")");
        System.out.println("RNN response:     (" + Utils.vectorToString(learnToOscillate.evaluateOutputsForWeights(best)) + ")");


    }
}
