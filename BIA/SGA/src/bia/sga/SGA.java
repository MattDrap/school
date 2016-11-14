
package bia.sga;
import java.util.Random;

/**
 * This main class represents population and implements evolution process.
 *
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class SGA {
    static Random generator = new Random();

    /**
     * Population of candidate solutions
     */
    static Individual[] population;

    /**
     * SGAKnapsack parameters
     */
    public static SGAParameters parameters = SGAParameters.getInstance();

    /**
     * Main function.
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception {
        run();
    }

    public static void run() throws Exception {

        parameters.readConfigFile();

        int cgen = 0;
        int totEvals = 0;

        // Initialise population
        population = initializePopulation();
        totEvals = population.length;

        // Generate statistic data and print report
        StatData.getStatistics(population);
        StatData.reportResults(totEvals);
        StatData.printBest(population);

        // Evolve population using either generational or steady-state replacement strategy
        evolvePopulation(population, totEvals);
        StatData.getBest(population);
    }

    /**
     * Evolves the @param population either using a generational or steady-state replacement strategy.
     *
     * @param population the population to be evolved.
     * @param totEvals   a number of fitness function evaluations that have been calculated
     *                   during an initialization phase.
     */
    public static void evolvePopulation(Individual[] population, int totEvals) {

        switch (parameters.getReplacementType()) {
            case 0:
                evolvePopGenerational(population, totEvals);
                break;
            case 1:
                evolvePopSteadyState(population, totEvals);
                break;
            default:
                System.err.println("ERROR - Bad value of replacementType variable. Check if its value is 0 or 1.");
                System.exit(1);
        }
    }

    /**
     * Evolves the @param population using a generational replacement strategy.
     *
     * @param population the population to be evolved.
     * @param totEvals   a number of fitness function evaluations that have been calculated
     *                   during an initialization phase.
     */
    public static void evolvePopGenerational(Individual[] population, int totEvals) {
    /* PUT YOUR CODE HERE */

    }

    /**
     * Evolves the @param population using a steady-state replacement strategy.
     *
     * @param population the population to be evolved.
     * @param totEvals   a number of fitness function evaluations that have been calculated
     *                   during an initialization phase.
     */
    public static void evolvePopSteadyState(Individual[] population, int totEvals) {
    /* PUT YOUR CODE HERE */

    }

    /**
     * Initialization of population.
     *
     * @return a number of fitness evaluations calculated during the population initialization
     */
    public static Individual[] initializePopulation() {
        int count = 0;

        // Allocate memory for individuals
        Individual[] newPop = new Individual[parameters.getPopSize()];
        
        // Generate individuals and calculate their fitness values.
        for (int ind = 0; ind < parameters.getPopSize(); ind++) {
            newPop[ind] = new Individual();
            newPop[ind].getFitness(); // Evaluate fitness of new individual.
            count++;
        }

        return newPop;
    }

    /**
     * @return an index of the worst individual in the current population.
     */
    public static int worstInPopulation(Individual[] population) {
        int worst = 0;
        
        if(parameters.getFunction().maximize()){
            for (int ind = 1; ind < population.length; ind++) {
                if (population[worst].fitness > population[ind].fitness)
                    worst = ind;
            }
        }
        else{
            for (int ind = 1; ind < population.length; ind++) {
                if (population[worst].fitness < population[ind].fitness)
                    worst = ind;
            }
        }

        return worst;
    }

    /**
     * Tournament selection with number of individuals in tournament.
     *
     * @return index of winner individual.
     */
    public static int tournamentSelection(Individual[] population) {
        int candidate;
        int winner = (int) (Math.random() * (population.length)); // First competitor of tournament selection.

        // Choose N individuals and select best one.
        // We chose randomly first individual 3 rows up, so there is only SGAKnapsack.tournament_size-1 random individuals to check. 
        for (int individualIndex = 0; individualIndex < parameters.getTournamentSize() - 1; individualIndex++) {
            candidate = generator.nextInt(population.length);
            if(population[candidate].betterThan(population[winner])){   // if candidate is better than the current winner
                winner = candidate;                                     // then update the winner
            }
        }

        return winner;
    }

    /**
     * Performs selection method according selectionType value.
     *
     * @return an index of one individual selected according to the chosen selection method
     */
    public static int selection(Individual[] population) {
        int selected = 0;

        switch (parameters.getSelectionType()) {
            case 0: // tournament
                selected = tournamentSelection(population);
                break;
            case 1: // random selection
                selected = generator.nextInt(population.length);
                break;
            default:
                System.err.println("ERROR - Bad value of selectionType variable.");
                System.exit(1);
        }

        return selected;
    }
}
