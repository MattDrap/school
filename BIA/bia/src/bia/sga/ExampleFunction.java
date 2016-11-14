package bia.sga;

/**
 * Created by drchajan on 18/03/14.
 */
public class ExampleFunction implements ContinuousFunction {
    private static SGAParameters parameters = SGAParameters.getInstance();
    private final double range;

    public ExampleFunction() {
        this.range = parameters.getRangeX();
    }

    @Override
    /**
     * Fitness Function Definition.
     * f(x) = sin(pi * x) + 10*sin(pi * x / rangeX)
     */
    public double f(double[] x) {
        return (Math.sin(Math.PI * x[0]) + 10.0 * Math.sin(Math.PI * x[0] / range));
    }

    @Override
    public int getDimension() {
        return 1;
    }

    @Override
    public void store(double[] x) {
    }
}
