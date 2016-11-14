package bia.sga;

/**
 * Created by drchajan on 18/03/14.
 */
public interface ContinuousFunction {
    double f(double[] x);   //--- calculates a fitness value in single-objective opt. problem

    double[] o(int[] x); //--- calculates objectives in multi-objective opt. problem
    
    int getDimension();
    
    boolean maximize(); //--- returns true if the function is to be maximized, otherwise returns false

    //used to store best solution
    void store(double[] x);
}
