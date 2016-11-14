package bia.sga;

/**
 * Created by drchajan on 18/03/14.
 */
public class RosenbrockFunction implements ContinuousFunction {
    @Override
    public double f(double[] x) {
        double a = 1 - x[0];
        double b = x[1] - x[0] * x[0];
        return a * a + 100 * b * b;
    }

    @Override
    public double[] o(int[] x) {
        
        return new double[1];
    }

    @Override
    public int getDimension() {
        return 2;
    }
    
    @Override
    public boolean maximize() {
        return false;
    }

    @Override
    public void store(double[] x) {
    }
}
