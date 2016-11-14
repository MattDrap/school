package bia.ann;

import bia.common.Utils;

import java.util.Random;

/**
 * Course: A4M33BIA
 * Multi-Layer Perceptrons (MLPs) and Back-propagation exercise.
 * This class covers Feedforward ANN (MLP) as well as learning algorithms.
 * Created by Jan Drchal on 25/02/14 drchajan@fel.cvut.cz.
 */
public class FeedforwardANN {
    //activation function gain
    public static final double SIGMOID_GAIN = 0.5;
    //gradient descent step size
    public static final double LEARNING_RATE = 0.9;
    //maximum number of epochs for Back-propagation  (1 epoch -> all patterns presented)
    public static final int MAX_EPOCHS = 20000;

    //weights[l][i][j] is a synaptic weight of an incoming connection to i-th neuron in layer l from j-th neuron in layer l-1
    private final double[][][] weights;
    private int numNeurons;
    private int numWeights;
    //activities[l][i] is an output of i-th neuron in layer l
    private double[][] activities;

    /**
     * Constructs ANN. The parameter layers describes the number of neurons in all layers starting with the input layer
     * ending with the output one. Each layer with an exception of the output layer is added a bias neuron.
     *
     * @param layers the successive elements of the array contain neuron count (without bias neurons)
     */
    public FeedforwardANN(int[] layers) {
        weights = new double[layers.length][][];
        activities = new double[layers.length][];
        int prevSize = 0;//the number of neurons in the previous layer
        for (int l = 0; l < layers.length; l++) {
            int size = (l == layers.length - 1) ? layers[l] : layers[l] + 1;//bias neuron in each layer with an exception of output layer
            weights[l] = new double[size][];
            int s = 0;
            if (l < layers.length - 1) {
                s = 1;
                weights[l][0] = new double[0];
            }
            for (int i = s; i < size; i++) {
                weights[l][i] = new double[prevSize];
                numWeights += prevSize;
            }
            activities[l] = new double[size];
            numNeurons += size;
            prevSize = size;
        }
    }

    /**
     * Allocates a 3 dimensional array for delta weights having same shape as the weights array.
     */
    private double[][][] allocateDeltaWeight() {
        double[][][] c = new double[weights.length][][];
        for (int l = 0; l < weights.length; l++) {
            c[l] = new double[weights[l].length][];
            for (int i = 0; i < weights[l].length; i++) {
                c[l][i] = new double[weights[l][i].length];
            }
        }
        return c;
    }

    /**
     * The elements of dw array are added to the corresponding elements of the target array. Both arrays must have the
     * same shape.
     */
    private static void accumulateDeltaWeights(double[][][] target, double[][][] dw) {
        for (int l = 0; l < target.length; l++) {
            for (int i = 0; i < target[l].length; i++) {
                if (target[l][i] != null) {
                    for (int j = 0; j < target[l][i].length; j++) {
                        target[l][i][j] += dw[l][i][j];
                    }
                }
            }
        }
    }

    /**
     * The elements of dw array are added to the corresponding elements of the weights array. Both arrays must have the
     * same shape.
     */
    private void applyDeltaWeights(double[][][] dw) {
        accumulateDeltaWeights(this.weights, dw);
    }

    /**
     * The number of neurons including bias neuron.
     */

    public int getNumInputs() {
        return getNumNeurons(0);
    }

    /**
     * Total number of neurons in the network.
     */
    public int getNumNeurons() {
        return numNeurons;
    }

    /**
     * The number of neurons in given layer (including bias neuron).
     */
    public int getNumNeurons(int layer) {
        return activities[layer].length;
    }

    /**
     * Total number of layers.
     */
    public int getNumLayers() {
        return activities.length;
    }

    /**
     * The number of output neurons (there is no bias neuron output layer).
     *
     * @return
     */
    public int getNumOutputs() {
        return getNumNeurons(weights.length - 1);
    }

    /**
     * Total number of weights in the network.
     */
    public int getNumWeights() {
        return numWeights;
    }

    /**
     * Returns a vector of all neuron activities in layer l.
     */
    public double[] getActivities(int layer) {
        return activities[layer].clone();
    }

    /**
     * Returns an activity of selected neuron in layer l.
     */
    public double getActivity(int layer, int neuron) {
        return activities[layer][neuron];
    }

    /**
     * Returns a vector of all neuron activities in output layer.
     */
    public double[] getOutputs() {
        return activities[getNumLayers() - 1].clone();
    }

    /**
     * Sets an activity of selected neuron in layer l.
     */
    public void setActivity(int layer, int neuron, double activity) {
        activities[layer][neuron] = activity;
    }

    /**
     * Returns a weight of connection between fromNeuron in layer l-1 and toNeuron in layer l.
     */
    public double getWeight(int l, int toNeuron, int fromNeuron) {
        return weights[l][toNeuron][fromNeuron];
    }

    /**
     * Sets a weight of connection between fromNeuron in layer l-1 and toNeuron in layer l.
     */
    public void setWeight(int layer, int toNeuron, int fromNeuron, double weight) {
        weights[layer][toNeuron][fromNeuron] = weight;
    }

    /**
     * Returns a number of connections incoming to neuron n in layer l (which is same as the number of neurons in layer l-1).
     */
    public int getNumIncomingConnections(int l, int n) {
        return weights[l][n].length;
    }

    /**
     * Randomizes all weights using uniform distribution in interval [-a;a]. The values 0.1<= a<=2 are considered to
     * be appropriate in most cases;
     */
    public void randomizeWeights(Random rnd, double a) {
        for (int l = 1; l < getNumLayers(); l++) {
            for (int i = 0; i < getNumNeurons(l); i++) {
                for (int j = 0; j < getNumIncomingConnections(l, i); j++) {
                    setWeight(l, i, j, -a + rnd.nextDouble() * 2 * a);
                }
            }
        }
    }

    /**
     * Loads input and propagates it through the whole network. All neurons are set activities.
     */
    private void propagate(double[] x) {
        for (int i = 0; i < x.length; i++) {// load inputs
            setActivity(0, i + 1, x[i]);
        }
        setActivity(0, 0, 1.0);//set bias neuron input to 1
        for (int l = 1; l < getNumLayers(); l++) {
            setActivity(l, 0, 1.0);//set bias neuron input to 1
            int s = l == getNumLayers() - 1 ? 0 : 1;
            for (int i = s; i < getNumNeurons(l); i++) {// for each neuron in layer
                double p = 0.0; //inner potential
                for (int j = 0; j < getNumNeurons(l - 1); j++) {
                    p += getWeight(l, i, j) * getActivity(l - 1, j);
                }
                setActivity(l, i, sigmoid(p));// neuron output
            }
        }
    }

    /**
     * Propagates the network and returns activities of all output neurons as a vector.
     */
    public double[] evaluate(double[] x) {
        propagate(x);
        return getActivities(getNumLayers() - 1);
    }

    /**
     * Logistic sigmoid.
     */
    private static double sigmoid(double x) {
        return 1.0 / (1.0 + Math.exp(-SIGMOID_GAIN * x));
    }

    /**
     * Logistic sigmoid derivative.
     *
     * @param y neuron activity
     */
    private static double sigmoidDerivative(double y) {
        return SIGMOID_GAIN * y * (1.0 - y);
    }

    /**
     * Evaluates ANN output as a class using one-of-N encoding.
     *
     * @param x input vector
     * @return class identification: 0..numOfOutputs()-1
     */
    public int evaluateClass(double[] x) {
        double[] y = evaluate(x);
        int maxIdx = 0;
        double max = y[0];

        for (int i = 1; i < y.length; i++) {
            if (y[i] > max) {
                maxIdx = i;
                max = y[i];
            }
        }

        return maxIdx;
    }

    /**
     * Back-propagation algorithm. Note, that in practise the learning is stopped when error on testing set starts to
     * increase which signalizes over-learning. Here, we stop after MAX_EPOCH for simplicity.
     *
     * @param trainX input patterns.
     * @param trainY output patterns.
     */
    public void learnBP(double[][] trainX, double[][] trainY) {
        double[][][] dw = allocateDeltaWeight();

        double bestE = Double.MAX_VALUE;
        for (int epoch = 1; epoch <= MAX_EPOCHS; epoch++) {

            for (int pattern = 0; pattern < trainX.length; pattern++) {

                propagate(trainX[pattern]);
                double[] y = getOutputs();
                double[] deltas = new double[getNumOutputs()];
                for (int i = 0; i < deltas.length; i++) {
                    deltas[i] = (trainY[pattern][i] - y[i]) * sigmoidDerivative(y[i]);
                }
                for (int l = getNumLayers() - 1; l > 0; l--) {
                    int s = l < getNumLayers() - 1 ? 1 : 0;
                    for (int i = 0; i < deltas.length; i++) {// for each neuron in layer
                        for (int j = 0; j < getNumIncomingConnections(l, i + s); j++) {// and neuron in previous layer
                            dw[l][i + s][j] = LEARNING_RATE * deltas[i] * getActivity(l - 1, j);
                        }
                    }

                    if (l > 1) {

                        double[] newDeltas = new double[getNumNeurons(l - 1) - 1];
                        for (int j = 0; j < newDeltas.length; j++) {
                            for (int i = 0; i < deltas.length; i++) {
                                newDeltas[j] += deltas[i] * getWeight(l, i + s, j + 1);
                            }
                            newDeltas[j] *= sigmoidDerivative(getActivity(l - 1, j + 1));
                        }
                        deltas = newDeltas;
                    }
                }// end layers
                applyDeltaWeights(dw);
            }// end patterns

            double rmse = computeRMSE(trainX, trainY);
            if (rmse < bestE) {
                bestE = rmse;
                System.out.println("epoch = " + epoch + ", RMSE = " + bestE);
            }
        }
    }

    /**
     * Simple random learning algorithm. Weights are randomly generated for given number of iterations. The best
     * solution is maintained.
     */
    public void learnRandom(Random rnd, int iterations, double[][] trainX, double[][] trainY) {
        double bestE = Double.MAX_VALUE;
        double[] bestW = null;
        for (int i = 1; i <= iterations; i++) {
            double[] w = Utils.randomVector(rnd, getNumWeights(), -5.0, 5.0);
            setWeights(w);
            double rmse = computeRMSE(trainX, trainY);
            if (rmse < bestE) {
                bestE = rmse;
                bestW = w;
                System.out.println("iteration = " + i + ", RMSE = " + bestE);
            }
        }
        setWeights(bestW);
    }

    /**
     * Computes the Root Mean Squared Error.
     *
     * @param examplesX input patterns
     * @param examplesY output patterns
     * @return RMSE
     */
    public double computeRMSE(double[][] examplesX, double[][] examplesY) {
        double sse = 0.0;
        for (int i = 0; i < examplesX.length; i++) {
            double[] y = evaluate(examplesX[i]);
            for (int j = 0; j < y.length; j++) {
                double e = examplesY[i][j] - y[j];
                sse += e * e;
            }
        }
        return Math.sqrt(sse / examplesX.length);
    }

    /**
     * Transforms the weights 3-dimensional array to a one dimensional array. Used by learnRandom();
     */
    public double[] asWeights() {
        double[] w = new double[getNumWeights()];
        int cnt = 0;
        for (int l = 1; l < getNumLayers(); l++) {
            for (int i = 0; i < getNumNeurons(l); i++) {
                for (int j = 0; j < getNumIncomingConnections(l, i); j++) {
                    w[cnt++] = getWeight(l, i, j);
                }
            }
        }
        return w;
    }

    /**
     * Set weights based on a one dimensional array w. Used by learnRandom();
     */
    public void setWeights(double[] w) {
        int cnt = 0;
        for (int l = 1; l < getNumLayers(); l++) {
            for (int i = 0; i < getNumNeurons(l); i++) {
                for (int j = 0; j < getNumIncomingConnections(l, i); j++) {
                    setWeight(l, i, j, w[cnt++]);
                }
            }
        }
    }

    /**
     * Prints a confusion matrix as well as the classification accuracy (true positives/all).  Actual classes
     * are shown in rows, ANN predictions in columns.
     *
     * @param examplesX input patterns
     * @param examplesY output patterns
     */
    public void printConfusionMatrix(double[][] examplesX, double[][] examplesY) {
        System.out.println("Confusion matrix");
        int classes = examplesY[0].length;
        int[][] m = new int[classes][classes];
        int tp = 0;// true positives
        for (int i = 0; i < examplesX.length; i++) {
            int r = 0;// convert 1-to-N to class number
            while (r < examplesY[i].length && examplesY[i][r] == 0.0) {
                r++;
            }
            int c = evaluateClass(examplesX[i]);
            m[r][c]++;
            if (r == c) {
                tp++;
            }
        }
        System.out.println("classification accuracy = " + (double) tp / examplesX.length);
        for (int[] row : m) {
            System.out.println(Utils.vectorToString(row));
        }
    }

    /**
     * Prints the ANN output for all input patterns.
     *
     * @param examplesX input patterns
     */
    public void printEvaluatedExamples(double[][] examplesX) {
        System.out.println("Evaluated examples");
        for (double[] x : examplesX) {
            System.out.println(Utils.vectorToString(x) + " | " + Utils.vectorToString(evaluate(x)));
        }
    }

}
