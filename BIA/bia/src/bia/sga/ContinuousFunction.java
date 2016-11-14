package bia.sga;

/**
 * Created by drchajan on 18/03/14.
 */
public interface ContinuousFunction {
    double f(double[] x);

    int getDimension();

    //used to store best solution
    void store(double[] x);
}
