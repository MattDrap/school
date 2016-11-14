package bia.ann;

import bia.common.Utils;

import java.util.Random;

/**
 * Course: A4M33BIA
 * Multi-Layer Perceptrons (MLPs) and Back-propagation exercise.
 * Created by Jan Drchal on 25/02/14 drchajan@fel.cvut.cz.
 */
public class Main {

    public static void main(String[] args) {
        Random rnd = new Random();

        double[][] inputVectors = Datasets.TWO_BOOLEAN_VARIABLES_X;
        double[][] outputVectors = Datasets.AND_Y;
//        double[][] outputVectors = Datasets.OR_Y;
//        double[][] outputVectors = Datasets.XOR_Y;

//        double[][] inputVectors = Datasets.IRIS_X;
//        double[][] outputVectors = Datasets.IRIS_Y;

        FeedforwardANN net = new FeedforwardANN(new int[]{2, 2, 2});
//        FeedforwardANN net = new FeedforwardANN(new int[]{4, 5, 5, 3});


        System.out.println("# neurons: " + net.getNumNeurons() + "(" + net.getNumInputs() + " inputs" + ")");
        System.out.println("# weights: " + net.getNumWeights());

        net.randomizeWeights(rnd, 0.7);

//        net.learnBP(inputVectors, outputVectors);
        net.learnRandom(rnd, 1000000, inputVectors, outputVectors);

        System.out.println();

        net.printEvaluatedExamples(inputVectors);
        System.out.println();
//        net.printWeightMatrix();
//        System.out.println();
        System.out.println("weight vector w = " + Utils.vectorToString(net.asWeights()));
        System.out.println();
        net.printConfusionMatrix(inputVectors, outputVectors);
    }
}
