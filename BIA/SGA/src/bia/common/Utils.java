package bia.common;

import java.util.Random;

/**
 * Course: A4M33BIA
 * Multi-Layer Perceptrons (MLPs) and Back-propagation exercise.
 * This class covers utility methods.
 * Created by Jan Drchal on 25/02/14 drchajan@fel.cvut.cz.
 */
public class Utils {
    public static String vectorToString(double[] v) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < v.length - 1; i++) {
            b.append(String.format("%.3f", v[i])).append(" ");
        }
        b.append(String.format("%.3f", v[v.length - 1]));
        return b.toString();
    }

    public static String vectorToString(int[] v) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < v.length - 1; i++) {
            b.append(v[i]).append(" ");
        }
        b.append(v[v.length - 1]);
        return b.toString();
    }

    public static double[] randomVector(Random rnd, int n, double min, double max) {
        double[] v = new double[n];
        for (int i = 0; i < n; i++) {
            v[i] = min + rnd.nextDouble() * (max - min);
        }
        return v;
    }

    /**
     * Gets index of the first occurrence of a maximum in the array.
     *
     * @param x
     * @return
     */
    public static int maxIndex(double[] x) {
        int i = 0;
        double m = x[i];
        for (int j = 1; j < x.length; j++) {
            if (x[j] > m) {
                i = j;
                m = x[j];
            }
        }
        return i;
    }
}
