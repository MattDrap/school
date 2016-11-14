package bia.rnn;

import bia.common.Utils;

import java.io.*;
import java.util.Arrays;

/**
 * Created by drchajan on 17/03/14.
 */
public class RNN implements Serializable {
    static final long serialVersionUID = -7588980448693010399L;

    public static final double SIGMOID_GAIN = 0.5;

    private double[][] weights;
    private double[] activities;

    private int numInputs;
    private int numHidden;
    private int numOutputs;
    private int numWeights;

    public RNN(int numInputs, int numHidden, int numOutputs) {
        this.numInputs = numInputs;
        this.numHidden = numHidden;
        this.numOutputs = numOutputs;
        this.weights = new double[numInputs + numOutputs + numHidden][numOutputs + numHidden];
        this.numWeights = (numInputs + numOutputs + numHidden) * (numOutputs + numHidden);
        this.activities = new double[numInputs + numOutputs + numHidden];
    }

    public int getNumInputs() {
        return numInputs;
    }

    public int getNumHidden() {
        return numHidden;
    }

    public int getNumOutputs() {
        return numOutputs;
    }

    public int getNumNeurons() {
        return getNumInputs() + getNumHidden() + getNumOutputs();
    }

    public int getNumHiddenOutput() {
        return getNumHidden() + getNumOutputs();
    }

    public int getNumWeights() {
        return numWeights;
    }

    public void setWeights(double[] w) {
        if (w.length != getNumWeights()) {
            throw new IllegalArgumentException("Weight vector must have " + getNumWeights() + " elements!");
        }
        int offset = 0;
        for (double[] row : weights) {
            System.arraycopy(w, offset, row, 0, row.length);
            offset += row.length;
        }
    }

    public double[] getWeights() {
        double[] w = new double[getNumWeights()];
        int offset = 0;
        for (double[] row : weights) {
            System.arraycopy(row, 0, w, offset, row.length);
            offset += row.length;
        }
        return w;
    }


    /**
     * Loads Inputs (does not set other neuron activities).
     *
     * @param i
     */
    public void loadInputs(double[] i) {
        if (i.length != getNumInputs()) {
            throw new IllegalArgumentException("Input vector must have " + getNumInputs() + " elements!");
        }
        System.arraycopy(i, 0, activities, 0, i.length);
    }

    /**
     * Sets activities of all neurons to 0.
     */

    public void resetActivities() {
        Arrays.fill(activities, 0.0);
    }

    public double[] getOutputs() {
        double[] o = new double[getNumOutputs()];
        System.arraycopy(activities, getNumInputs(), o, 0, o.length);
        return o;
    }

    /**
     * Gets index of an output neuron having highest activation
     *
     * @return
     */
    public int getClassification() {
        return Utils.maxIndex(getOutputs());

    }

    private static double sigmoid(double x) {
        return 1.0 / (1.0 + Math.exp(-SIGMOID_GAIN * x));
    }

    public void propagate() {
    // YOUR CODE HERE
    }

    public void serialize(String fileName) {
        try {
            FileOutputStream fileOut =
                    new FileOutputStream(fileName);
            ObjectOutputStream out = new ObjectOutputStream(fileOut);
            out.writeObject(this);
            out.close();
            fileOut.close();
        } catch (IOException i) {
            i.printStackTrace();
        }
    }

    public static RNN deserialize(String fileName) {
        RNN e = null;
        try {
            FileInputStream fileIn = new FileInputStream(fileName);
            ObjectInputStream in = new ObjectInputStream(fileIn);
            e = (RNN) in.readObject();
            in.close();
            fileIn.close();
        } catch (IOException i) {
            i.printStackTrace();
        } catch (ClassNotFoundException c) {
            c.printStackTrace();
        }
        return e;
    }
}
