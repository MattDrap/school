/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.tsp;

import bia.common.Utils;

/**
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class TSPStatData {

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
    public static TSPParameters parameters = TSPParameters.getInstance();

    /**
     * Stores statistics of actual population.
     *
     * @param p population of individuals
     */
    public static void getStatistics(TSPIndividual[] p) {
        // Init statistics data
        fbest = Double.MAX_VALUE;
        fworst = Double.MIN_VALUE;
        favg = 0.0;
        fsum = 0.0;
        indbest = 0;
        indworst = 0;

        for (int i = 0; i < parameters.getPopSize(); i++) {
            if (fbest >= p[i].fitness) {
                fbest = p[i].fitness;   // Store best fitness value.
                indbest = i;              // Store best fitness individual index.
            }
            if (fworst <= p[i].fitness) {
                fworst = p[i].fitness;    // Store worst fitness value.
                indworst = i;             // Stroe worst fitness individual index.
            }
            fsum += p[i].fitness;           // Calculate fitness sum of whole population.
        }

        favg = fsum / parameters.getPopSize();  // Calculate average fitness value in population.
    }

    /**
     * Prints evolution progress information on standard output.
     *
     * @param evals number of total evaluations during evolution.
     */
    public static void reportResults(int evals) {
        System.out.println("evals: " + evals + "\t fbest: " + fbest + "\t favg: " + favg);
    }

    /**
     * Prints value of individual and its fitness value on standard output. It also stores the best individual in file.
     *
     * @param p population of individuals.
     */
    public static void printBest(TSPIndividual[] p) {
        
        // Print the values of x on standard output.
        System.out.println("\tbest solution: " + Utils.vectorToString(p[indbest].genes) + "\n\tfitness " + p[indbest].fitness);
    }
}
