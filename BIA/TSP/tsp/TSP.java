
package bia.tsp;

import bia.tsp.TSPviz;
//import com.csvreader.CsvWriter;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;
import javax.swing.JFrame;

/**
 * This main class represents population and implements evolution process.
 *
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class TSP {

    //--- Input data.
    static File dataset;
    
    static int nbCities;    //--- number of cities
    static double[][] cityCoordinates = new double[nbCities][2];      //--- table of city coordinates
    static int[][] tableOfCityDistances;    //--- distances are rounded to integer values
    
    /**
     * Old and new population.
     */
    static TSPIndividual[] oldPop;
    static TSPIndividual[] newPop;

    /**
     * Newly generated individuals
     */
    static TSPIndividual[] offspringPop;

    /**
     * SGA parameters
     */
    public static TSPParameters parameters = TSPParameters.getInstance();

    /**
     * Visualization
     */
    public static TSPviz tspVisualizator = null;  
    public static JFrame aFrame = null;
    
    static Random generator = new Random();

    /**
     * Main function.
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception {

        parameters.readConfigFile();
        
        dataset = new File(parameters.getDataset());
        if (dataset.exists()) {
            importDatasetTSP();
        }
        else{
            System.out.println("Dataset file does not exist!");
            System.exit(0);
        }
        
        run();
    }

    public static void run() throws Exception {

        int cgen = 0;
        int totEvals = 0;

        // Allocate memory for arrays
        newPop = new TSPIndividual[parameters.getPopSize()];
        oldPop = new TSPIndividual[parameters.getPopSize()];
        offspringPop = new TSPIndividual[2];

        // Initialise population.
        totEvals = initializePopulation(oldPop);

        // Generate statistic data and print results
        TSPStatData.getStatistics(oldPop);
        TSPStatData.reportResults(totEvals);
        TSPStatData.printBest(oldPop);
        //--- Visualization
        if(parameters.getVisualization())
            visualizeTour(oldPop[TSPStatData.indbest]);

        // Evolve population using either generational or steady-state replacement strategy
        evolvePopulation(oldPop, totEvals);
        
        //--- Visualization
        if(parameters.getVisualization())
            updateVisualization(oldPop[TSPStatData.indbest]);
    }

    /**
     * Evolves the @param population either using a generational or steady-state replacement strategy.
     *
     * @param population the population to be evolved.
     * @param totEvals   a number of fitness function evaluations that have been calculated
     *                   during an initialization phase.
     */
    public static void evolvePopulation(TSPIndividual[] population, int totEvals) {

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
    public static void evolvePopGenerational(TSPIndividual[] population, int totEvals) {

        // While the termination criterion is not satisfied ...
        while (totEvals < parameters.getEvaluations()) {
            int chroms_generated = 0;

            // Elitism. Copy best individual from old population.
            newPop[chroms_generated++] = population[TSPStatData.indbest].clone();

            // While new population is not filled...
            while (chroms_generated < parameters.getPopSize()) {
                int[] par = selection(population);
                TSPIndividual parent1 = population[par[0]].clone();
                TSPIndividual parent2 = population[par[1]].clone();
                // Creates two new individuals.
                if (Math.random() < parameters.getPC()) {
                    offspringPop = parent1.crossover(parent2);
                    if (Math.random() < parameters.getPM()) {   //--- mutate the offspring with probability pM
                        offspringPop[0].mutate();
                        offspringPop[1].mutate();
                    }
                } else {    //--- If parents do not cross then always mutate
                    offspringPop[0] = parent1;
                    offspringPop[1] = parent2;
                    offspringPop[0].moveMutation();     //--- or swapMutation()
                    offspringPop[1].moveMutation();
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
            TSPIndividual[] tempPop = null;
            tempPop = population;
            population = newPop;
            newPop = tempPop;

            // Generate statistic data and print results.
            TSPStatData.getStatistics(population);
            TSPStatData.reportResults(totEvals);
            TSPStatData.printBest(population);
            if(!population[TSPStatData.indbest].checkValidity()){
                System.err.println("Invalid solution generated");
                System.exit(1);
            }
        }
    }

    /**
     * Evolves the @param population using a steady-state replacement strategy.
     *
     * @param population the population to be evolved.
     * @param totEvals   a number of fitness function evaluations that have been calculated
     *                   during an initialization phase.
     */
    public static void evolvePopSteadyState(TSPIndividual[] population, int totEvals) {
        int generationCounter = 0;

        // While the termination criterion is not satisfied ...
        while (totEvals < parameters.getEvaluations()) {
            int replacementIndex;   //--- index of the individual to be replaced by a newly generated offspring

            int[] par = selection(population);
            TSPIndividual parent1 = population[par[0]].clone();
            TSPIndividual parent2 = population[par[1]].clone();
            // Creates two new individuals
            if (Math.random() < parameters.getPC()) {
                offspringPop = parent1.crossover(parent2);  //--- create offspring by a crossover
                if (Math.random() < parameters.getPM()) {   //--- mutate the offspring with probability pM
                    offspringPop[0].mutate();     //--- or swapMutation()
                    offspringPop[1].mutate();
                }
            } else {
                offspringPop[0] = parent1;
                offspringPop[1] = parent2;
                offspringPop[0].mutate();
                offspringPop[1].mutate();
            }
            // Calculates fitness of new individuals
            offspringPop[0].getFitness();
            offspringPop[1].getFitness();
            totEvals += 2;  // Increase number of evaluations done

            // Find an individual to be replaced by the first child and replace it
            replacementIndex = worstInPopulation(population);
            population[replacementIndex] = offspringPop[0];
            // Find an individual to be replaced by the second child and replace it
            replacementIndex = worstInPopulation(population);
            population[replacementIndex] = offspringPop[1];

            //--- Regular reports
            generationCounter++;
            if (generationCounter == population.length / 2) {
                // Generate statistic data
                TSPStatData.getStatistics(population);
                TSPStatData.reportResults(totEvals);
                TSPStatData.printBest(population);
                //---
                if(!population[TSPStatData.indbest].checkValidity()){
                    System.err.println("Invalid solution generated");
                    System.exit(1);
                }
                //---
                generationCounter = 0;
            }
        }

        //--- Final report
        // Generate statistic data and print results.
        TSPStatData.getStatistics(population);
        TSPStatData.reportResults(totEvals);
        TSPStatData.printBest(population);
    }

    /**
     * Initialization of population.
     *
     * @return a number of fitness evaluations calculated during the population initialization
     */
    public static int initializePopulation(TSPIndividual[] population) {
        int count = 0;

        // Generate individuals in parent population and calculate their fitness values.
        for (int ind = 0; ind < parameters.getPopSize(); ind++) {
            if(parameters.getInitializationType() == 0)
                population[ind] = new TSPIndividual();      //--- random initialization
            else{
                population[ind] = new TSPIndividual(false); //--- nearest neighbor initialization
                population[ind].initializeByNearestNeighbor();
            }
            population[ind].getFitness(); // Evaluate fitness of new individual.
            count++;
        }

        return count;
    }

    /**
     * @return an index of the worst individual in the current population.
     */
    public static int worstInPopulation(TSPIndividual[] population) {
        int worst = 0;

        for (int ind = 1; ind < parameters.getPopSize(); ind++) {
            if (population[worst].fitness < population[ind].fitness)    //--- The higher fitness the worse solution
                worst = ind;
        }

        return worst;
    }

    /**
     * Makes deep copy of individual in population p with index from and stores it to population p2 to index to.
     */
    public static void copyIndividual(TSPIndividual source, int to, TSPIndividual[] population) {
        population[to] = source;
    }

    /**
     * Tournament selection with number of individuals in tournament.
     *
     * @return index of winner individual.
     */
    public static int tournamentSelection(TSPIndividual[] p) {
        int index;
        int winnerIndex = (int) (Math.random() * (parameters.getPopSize())); // First member of tournament selection.
        double winnerFitness = p[winnerIndex].fitness;

        // Choose N individuals and select best one.
        // We chose randomly first individual 3 rows up, so there is only SGA.tournament_size-1 random individuals to check. 
        for (int individualIndex = 0; individualIndex < parameters.getTournamentSize() - 1; individualIndex++) {
            index = (int) (Math.random() * (parameters.getPopSize()));
            if (p[index].fitness < winnerFitness) {
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
    public static int[] selection(TSPIndividual[] p) {
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
    
    /**
     * Imports data from specified input file. Dataset must be specified before
     * {@link init()} method invocation
     * 
     * Data type: TSP
     */
    private static void importDatasetTSP() {

        BufferedReader br;
        String temp;
        String noNumRegex = "[^0-9]";

        try {
            br = new BufferedReader(new FileReader(dataset));
                       
            temp = br.readLine();
            String name = temp.replaceAll("NAME:\\s", "");
            temp = br.readLine();   //--- TYPE: TSP
            temp = br.readLine();   //--- COMMENT: 
            temp = br.readLine();   //--- DIMENSION:
            temp = temp.replaceAll(noNumRegex, "");
            nbCities = Integer.parseInt(temp);
            br.readLine();   //--- EDGE_WEIGHT_TYPE: EUC_2D
            temp = br.readLine();   //--- NODE_COORD_SECTION
            
            //--- 
            cityCoordinates = new double[nbCities][2];      //--- table of city coordinates
            
            for(int i = 0; i < nbCities; i++){
                double x = 0.0, y = 0.0;
                temp = br.readLine();
                String[] line = temp.split("\\s++");
                int whiteSpace = (line[0].compareTo("") == 0) ? 1 : 0;
                //--- x coord
                try{
                    x = Double.parseDouble(line[whiteSpace + 1]);
                } catch (NumberFormatException e) {
                    System.out.println("Wrong data format!!!");
                    System.exit(1);     //--- spatny format vstupnich dat
                }                        
                //--- y coord
                try{
                    y = Double.parseDouble(line[whiteSpace + 2]);
                } catch (NumberFormatException e) {
                    System.out.println("Wrong data format!!!");
                    System.exit(1);
                }                        
                //---
                cityCoordinates[i][0] = x;
                cityCoordinates[i][1] = y;
            }
            br.close();

            //--- Calculate table of distances between nodes
            tableOfCityDistances = new int[nbCities][nbCities];
            for(int i = 0; i < nbCities; i++){
                for(int j = 0; j < nbCities; j++){
                    if(i == j){
                        tableOfCityDistances[i][j] = 0;
                    }
                    else{
                        int dist = 0;
                        dist = (int)Math.round(Math.sqrt(Math.pow(cityCoordinates[i][0]-cityCoordinates[j][0], 2.0) + Math.pow(cityCoordinates[i][1]-cityCoordinates[j][1], 2.0)));
                        tableOfCityDistances[i][j] = dist;
                    }
                }
            }
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
    }
    
    public static void visualizeTour(TSPIndividual solution) {

        // Init graphics
        tspVisualizator = new TSPviz();  

        // Load cities.
        TSPviz.N = solution.genes.length;
        TSPviz.nodes = new Node[TSPviz.N];
        for (int i = 0; i < TSPviz.N; i++) {
            TSPviz.nodes[i] = new Node(cityCoordinates[solution.genes[i]][0], cityCoordinates[solution.genes[i]][1]);
            if(TSPviz.nodes[i].x < TSPviz.minX) TSPviz.minX = TSPviz.nodes[i].x;
            if(TSPviz.nodes[i].x > TSPviz.maxX) TSPviz.maxX = TSPviz.nodes[i].x;
            if(TSPviz.nodes[i].y < TSPviz.minY) TSPviz.minY = TSPviz.nodes[i].y;
            if(TSPviz.nodes[i].y > TSPviz.maxY) TSPviz.maxY = TSPviz.nodes[i].y;
        }

        // Get coeficient for better drawing.
        TSPviz.multCoefX = (TSPviz.frameSize - 40) / Math.abs(TSPviz.maxX - TSPviz.minX);
        TSPviz.multCoefY = (TSPviz.frameSize - 60) / Math.abs(TSPviz.maxY - TSPviz.minY);

        //create a new frame to which we will add a canvas
        aFrame = new JFrame();
        //aFrame.setAction(JFrame.EXIT_ON_CLOSE);
        aFrame.setSize(TSPviz.frameSize, TSPviz.frameSize);
        aFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        //add the canvas
        aFrame.add(tspVisualizator);
        aFrame.setTitle("Tour length: " + solution.fitness);

        aFrame.setVisible(true);
    }

    public static void updateVisualization(TSPIndividual solution) {

        // Init graphics
        if(tspVisualizator == null){
            System.err.println("Visualizator is not initialized!");
            System.exit(1);
        } 

        // Load cities.
        TSPviz.N = solution.genes.length;
        TSPviz.nodes = new Node[TSPviz.N];
        for (int i = 0; i < TSPviz.N; i++) {
            TSPviz.nodes[i] = new Node(cityCoordinates[solution.genes[i]][0], cityCoordinates[solution.genes[i]][1]);
        }
                              
        //add the canvas
        aFrame.add(tspVisualizator);
        aFrame.setTitle("Tour length: " + solution.fitness);

        aFrame.setVisible(true);
    }
}
