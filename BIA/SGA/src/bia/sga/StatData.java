/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.sga;

import bia.common.Utils;
import java.util.Arrays;

/**
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class StatData {

    /**
     * Best fitness in the population (best-so-far).
     */
    public static double fbest;

    /**
     * Average fitness of the chromosomes.
     */
    public static double favg;

    /**
     * Fitness of the worst chromosome.
     */
    public static double fworst;

    /**
     * Sum of fitness values over the whole population.
     */
    public static double fsum;

    /**
     * Index of the best individual.
     */
    public static int indbest;

    /**
     * Index of the worst individual
     */
    public static int indworst;

    /**
     * SGA parameters
     */
    public static SGAParameters parameters = SGAParameters.getInstance();

    /**
     * Stores statistics of actual population.
     *
     * @param population population of individuals
     */
    public static void getStatistics(Individual[] population) {
        // Init statistics data for maximization problem
        if(parameters.getFunction().maximize()){
            fbest = -Double.MAX_VALUE;
            fworst = Double.MAX_VALUE;
        }
        // Init statistics data for minimization problem
        else{
            fbest = Double.MAX_VALUE;
            fworst = -Double.MAX_VALUE;
        }
        favg = 0.0;
        fsum = 0.0;
        indbest = 0;
        indworst = 0;

        for (int i = 0; i < parameters.getPopSize(); i++) {
            if(parameters.getFunction().maximize()){
                if (fbest <= population[i].fitness) {
                    fbest = population[i].fitness;   // Store best fitness value.
                    indbest = i;              // Store best fitness individual index.
                }
                if (fworst >= population[i].fitness) {
                    fworst = population[i].fitness;    // Store worst fitness value.
                    indworst = i;             // Stroe worst fitness individual index.
                }
            }
            else{
                if (fbest >= population[i].fitness) {
                    fbest = population[i].fitness;   // Store best fitness value.
                    indbest = i;              // Store best fitness individual index.
                }
                if (fworst <= population[i].fitness) {
                    fworst = population[i].fitness;    // Store worst fitness value.
                    indworst = i;             // Stroe worst fitness individual index.
                }
            }
            fsum += population[i].fitness;           // Calculate fitness sum of whole population.
        }

        favg = fsum / population.length;  // Calculate average fitness value in population.
    }

    /**
     * Prints evolution progress information on standard output.
     *
     * @param evals number of total evaluations during evolution.
     */
    /**
     * Prints evolution progress information on standard output.
     *
     * @param evals number of total evaluations during evolution.
     */
    public static void reportResults(int evals) {
        System.out.println("\nevals: " + evals + "\t fbest: " + fbest + "\t favg: " + favg);
    }

    /**
     * Prints value of individual and its fitness value on standard output. It also stores the best individual in file.
     *
     * @param p population of individuals.
     */
    public static void printBest(Individual[] p) {
        double[] x = getBest(p);

        // Print the values of x on standard output.
        System.out.println("\tbest solution variables: " + Utils.vectorToString(x));
        System.out.println("\tbest solution genes: " + Utils.vectorToString(p[indbest].genes));
        System.out.println("\tbest solution fitness: " + p[indbest].fitness);
        parameters.getFunction().store(x);
    }

    public static double[] getBest(Individual[] p) {
        double[] x;

        // Decode parameter x
        x = p[indbest].decodeGenes();
        x = p[indbest].normalizeX(x);
        return x;
    }
}
