
package bia.sga;

/**
 * This main class represents population and implements evolution process.
 *
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class SGA {

    /**
     * Old and new population.
     */
    static Individual[] oldPop;
    static Individual[] newPop;

    /**
     * Newly generated individuals
     */
    static Individual[] offspringPop;

    /**
     * SGA parameters
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

    public static double[] run() throws Exception {

        parameters.readConfigFile();

        int cgen = 0;
        int totEvals = 0;

        // Allocate memory for arrays
        newPop = new Individual[parameters.getPopSize()];
        oldPop = new Individual[parameters.getPopSize()];
        offspringPop = new Individual[2];

        // Initialise population.
        totEvals = initializePopulation(oldPop);

        // Generate statistic data.
        StatData.getStatistics(oldPop);
        // Print results.
        StatData.reportResults(totEvals);
        StatData.printBest(oldPop);

        // Evolve population using either generational or steady-state replacement strategy
        evolvePopulation(oldPop, totEvals);
        return StatData.getBest(oldPop);
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

        // While the termination criterion is not satisfied ...
        while (totEvals < parameters.getEvaluations()) {
            int chroms_generated = 0;

            // Elitism. Copy best individual from old population.
            newPop[chroms_generated++] = oldPop[StatData.indbest].clone();

            // While new population is not filled...
            while (chroms_generated < parameters.getPopSize()) {
                int[] par = selection(oldPop);
                Individual parent1 = oldPop[par[0]].clone();
                Individual parent2 = oldPop[par[1]].clone();
                // Creates two new individuals.
                if (Math.random() < parameters.getPC()) {
                    offspringPop = parent1.crossover(parent2);
                    offspringPop[0].mutation();
                    offspringPop[1].mutation();
                } else {
                    offspringPop[0] = parent1;
                    offspringPop[1] = parent2;
                    offspringPop[0].mutation();
                    offspringPop[1].mutation();
                }
                // Calculates fitness of new individuals.
                offspringPop[0].getFitness();
                offspringPop[1].getFitness();
                totEvals += 2;  // Increase number of evaluations done.

                // Get offspring to new parent population.
                newPop[chroms_generated++] = offspringPop[0];
                if (chroms_generated < parameters.getPopSize())
                    newPop[chroms_generated++] = offspringPop[1];
            }

            // Swap oldPop and newPop
            Individual[] tempPop = new Individual[parameters.getPopSize()];
            tempPop = oldPop;
            oldPop = newPop;
            newPop = oldPop;

            // Generate statistic data.
            StatData.getStatistics(oldPop);

            // Print results.
            StatData.reportResults(totEvals);
            StatData.printBest(oldPop);
        }
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

        int generationCounter = 0;

        // While the termination criterion is not satisfied ...
        while (totEvals < parameters.getEvaluations()) {
            int replacementIndex;   //--- index of the individual to be replaced by a newly generated offspring

            int[] par = selection(oldPop);
            Individual parent1 = oldPop[par[0]].clone();
            Individual parent2 = oldPop[par[1]].clone();
            // Creates two new individuals
            if (Math.random() < parameters.getPC()) {
                offspringPop = parent1.crossover(parent2);  //--- create offspring by a crossover
                offspringPop[0].mutation();                 //--- mutate the offspring
                offspringPop[1].mutation();
            } else {
                offspringPop[0] = parent1;
                offspringPop[1] = parent2;
                offspringPop[0].mutation();     //--- just mutate the parents
                offspringPop[1].mutation();
            }
            // Calculates fitness of new individuals
            offspringPop[0].getFitness();
            offspringPop[1].getFitness();
            totEvals += 2;  // Increase number of evaluations done

            // Find an individual to be replaced by the first child and replace it
            replacementIndex = worstInPopulation(oldPop);
            oldPop[replacementIndex] = offspringPop[0];
            // Find an individual to be replaced by the second child and replace it
            replacementIndex = worstInPopulation(oldPop);
            oldPop[replacementIndex] = offspringPop[1];

            //--- Regular reports
            generationCounter++;
            if (generationCounter == oldPop.length / 2) {
                // Generate statistic data
                StatData.getStatistics(oldPop);
                // Print results
                StatData.reportResults(totEvals);
                StatData.printBest(oldPop);
                //---
                generationCounter = 0;
            }
        }

        //--- Final report
        // Generate statistic data
        StatData.getStatistics(oldPop);
        // Print results
        StatData.reportResults(totEvals);
        StatData.printBest(oldPop);
    }

    /**
     * Initialization of population.
     *
     * @return a number of fitness evaluations calculated during the population initialization
     */
    public static int initializePopulation(Individual[] population) {
        int count = 0;

        // Generate individuals in parent population and calculate their fitness values.
        for (int ind = 0; ind < parameters.getPopSize(); ind++) {
            population[ind] = new Individual();
            population[ind].getFitness(); // Evaluate fitness of new individual.
            count++;
        }

        return count;
    }

    /**
     * @return an index of the worst individual in the current population.
     */
    public static int worstInPopulation(Individual[] population) {
        int worst = 0;

        for (int ind = 1; ind < parameters.getPopSize(); ind++) {
            if (population[worst].fitness > population[ind].fitness)
                worst = ind;
        }

        return worst;
    }

    /**
     * Makes deep copy of individual in population p with index from and stores it to population p2 to index to.
     */
    public static void copyIndividual(Individual source, int to, Individual[] population) {
        population[to] = source;
    }

    /**
     * Tournament selection with number of individuals in tournament.
     *
     * @return index of winner individual.
     */
    public static int tournamentSelection(Individual[] p) {
        int index;
        int winnerIndex = (int) (Math.random() * (parameters.getPopSize())); // First member of tournament selection.
        double winnerFitness = p[winnerIndex].fitness;

        // Choose N individuals and select best one.
        // We chose randomly first individual 3 rows up, so there is only SGA.tournament_size-1 random individuals to check. 
        for (int individualIndex = 0; individualIndex < parameters.getTournamentSize() - 1; individualIndex++) {
            index = (int) (Math.random() * (parameters.getPopSize()));
            if (p[index].fitness > winnerFitness) {
                winnerFitness = p[index].fitness;
                winnerIndex = index;
            }
        }

        return winnerIndex;
    }

    /**
     * Performs selection method according selectionType value.
     *
     * @return array of two indexes selected by selection methods.
     */
    public static int[] selection(Individual[] p) {
        int[] chosen = new int[2];

        switch (parameters.getSelectionType()) {
            case 0:
                chosen[0] = tournamentSelection(p);
                chosen[1] = chosen[0];
                while (chosen[0] == chosen[1])
                    chosen[1] = tournamentSelection(p);
                break;
            default:
                System.err.println("ERROR - Bad value of selectionType variable. Check if its value is 0.");
                System.exit(1);
        }

        return chosen;
    }
}
