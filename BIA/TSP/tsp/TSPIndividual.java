/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.tsp;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;


/**
 * @author Jiri Kubalik
 */
public class TSPIndividual {

    /**
     * Genes - a vector of integers, a permutation of N cities.
     */
    public int[] genes;

    /**
     * Fitness of individual.
     */
    public double fitness;

    /**
     * SGA parameters
     */
    public static TSPParameters parameters = TSPParameters.getInstance();

    static Random generator = new Random();
    
    /**
     * Constructor. Generates random individual.
     */
    public TSPIndividual() {

        // Allocate memory for genes array.
        this.genes = new int[TSP.nbCities];
        
        // Randomly initialise genes of individual.
        for (int i = 0; i < genes.length; i++)
            this.genes[i] = i;
        
        //--- Shuffle genes.
        // Randomly initialise genes of individual.
        for (int i = 0; i < genes.length; i++) {
            int ind1 = generator.nextInt(genes.length);
            int ind2 = generator.nextInt(genes.length);
            int temp = this.genes[ind1];
            this.genes[ind1] = this.genes[ind2];
            this.genes[ind2] = temp;
        }
    }

    /**
     * Constructor generating empty individual without its genes defined.
     *
     * @param b dump parameter.
     */
    public TSPIndividual(boolean b) {
        // Only allocate memory for genes array.
        this.genes = new int[TSP.nbCities];
    }

    /**
     * Cloning method for creating deep copies of individual instances.
     *
     * @return
     */
    @Override
    public TSPIndividual clone() {
        TSPIndividual individual = new TSPIndividual(false); // Create empty idividual.
        for (int geneIter = 0; geneIter < TSP.nbCities; geneIter++) {
            individual.genes[geneIter] = this.genes[geneIter];
        }

        individual.fitness = this.fitness;

        return individual;
    }

    public int findNearestNeighbor(int currentCity, ArrayList<Integer> cities){
        int bestCity = cities.get(0);
        
        int i = 1;
        while(i < cities.size()){
            int candidate = cities.get(i);
            if(TSP.tableOfCityDistances[candidate][currentCity] < TSP.tableOfCityDistances[bestCity][currentCity])
                bestCity = candidate;
            i++;
        }
        
        return bestCity;
    }
    
    /**
     * Initializes a tour by using the nearest neighbor heuristic.
     */
    public void initializeByNearestNeighbor() {
        int i;
        ArrayList<Integer> availableCities = new ArrayList<>();    //--- cities that can be added to the constructed tour

        for(i = 0; i < this.genes.length; i++)
            availableCities.add(new Integer(i));
        
        //--- start with randomly chosen city
        i = 0;
        int currentCity = availableCities.remove(generator.nextInt(availableCities.size()));
        this.genes[i] = currentCity;
        i++;
        //--- build the rest of the tour
        while(i < this.genes.length){
            currentCity = findNearestNeighbor(currentCity, availableCities);
            this.genes[i] = currentCity;
            availableCities.remove(new Integer(currentCity));
            i++;
        }
    }
    
    /**
     * Fitness function calculation.
     */
    public void getFitness() {
        int f = 0;

        //--- Calculate total distance of the tour through the sequence of cities
        //--- given in this.genes.
        for(int i = 0; i < TSP.nbCities-1; i++){
            f += TSP.tableOfCityDistances[this.genes[i]][this.genes[i+1]];
        }
        f += TSP.tableOfCityDistances[this.genes[TSP.nbCities-1]][this.genes[0]];

        this.fitness = f;
    }

    /**
     * Builds an edgeMap from tours in genes1 and genes2.
     *
     * @return edgeMap
     */
    public ArrayList<ArrayList<Integer>> buildEdgeMap(int[] genes1, int[] genes2){
        ArrayList<ArrayList<Integer>> edgeMap = new ArrayList<ArrayList<Integer>>();
        
        for(int i = 0; i < TSP.nbCities; i++){
            ArrayList<Integer> cityNeighbors = new ArrayList<>();
            for(int j = 0; j < TSP.nbCities; j++){
                if(genes1[j] == i){ //--- Process neighbors of city 'i' in the first parent
                    Integer neighbor = new Integer(genes1[(j+1) % TSP.nbCities]); //--- add right neighbor of city 'i'
                    if(!cityNeighbors.contains(neighbor))
                        cityNeighbors.add(neighbor);   
                    //---
                    neighbor = new Integer(genes1[(j+TSP.nbCities-1) % TSP.nbCities]); //--- add left neighbor of city 'i'
                    if(!cityNeighbors.contains(neighbor))
                        cityNeighbors.add(neighbor);   
                }
                if(genes2[j] == i){ //--- Process neighbors of city 'i' in the second parent
                    Integer neighbor = new Integer(genes2[(j+1) % TSP.nbCities]); //--- add right neighbor of city 'i'
                    if(!cityNeighbors.contains(neighbor))
                        cityNeighbors.add(neighbor);   
                    //---
                    neighbor = new Integer(genes2[(j+TSP.nbCities-1) % TSP.nbCities]); //--- add left neighbor of city 'i'
                    if(!cityNeighbors.contains(neighbor))
                        cityNeighbors.add(neighbor);   
                }
            }
            //--- Add cityNeighbors to the edgeMap
            edgeMap.add(cityNeighbors);
        }
        
        return edgeMap;
    }
    
    /**
     * Updates edgeMap - removes the city from the neighbor list of all cities.
     */
    public void updateEdgeMap(ArrayList<ArrayList<Integer>> edgeMap, int city){
        
        Integer c = new Integer(city);
        for(int i = 0; i < edgeMap.size(); i++){
            ArrayList<Integer> nl = edgeMap.get(i);
            if(nl.contains(c)){
                nl.remove(c);
                edgeMap.set(i, nl);
            }
        }
    }

    /**
     * Chooses next city to go from the city.
     */
    public int chooseNextCity(ArrayList<ArrayList<Integer>> edgeMap, int city, ArrayList<Integer> availableCities){
        int nextCity;

        //--- If the list of neighbors of the city is not empty then choose randomly one neighbor.
        if(!edgeMap.get(city).isEmpty()){
            nextCity = edgeMap.get(city).get(generator.nextInt(edgeMap.get(city).size()));
        }
        //--- Otherwise, choose randomly one city that is not yet used in the constructed tour
        else{  
            nextCity = availableCities.get(generator.nextInt(availableCities.size()));
        }

        return nextCity;
    }

    /**
     * Edge-recombination crossover.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public TSPIndividual[] edgeRecombinationCrossover(TSPIndividual mate) {
        int i;
        TSPIndividual[] children = new TSPIndividual[2];
        ArrayList<ArrayList<Integer>> edgeMap;  //--- pro kazdy arc je zde seznam nejblizsich 
        ArrayList<Integer> availableCities = new ArrayList<>();    //--- cities that can be added to the constructed tour

        //--- Initialize children
        children[0] = new TSPIndividual(false);
        children[1] = new TSPIndividual(false);
        
        //--- Create 1. child
        //--- Build edge map
        edgeMap = buildEdgeMap(this.genes, mate.genes);
        //--- Initialize list of available cities
        for(i = 0; i < genes.length; i++)
            availableCities.add(new Integer(i));
        //--- Construct a new tour by using the edge map
        i = 0;
        int currentCity = generator.nextInt(genes.length);    //--- start from randomly chosen city
        children[0].genes[i] = currentCity;                   //--- add currentCity to the constructed tour
        availableCities.remove(Integer.valueOf(currentCity)); //--- update list of available cities
        updateEdgeMap(edgeMap, currentCity);                  //--- remove all occurences of the currentCity from the edgeMap
        i++;
        while(i < genes.length){
            currentCity = chooseNextCity(edgeMap, currentCity, availableCities);   //--- choose next city from the edgeMap
            children[0].genes[i] = currentCity;
            availableCities.remove(Integer.valueOf(currentCity));
            updateEdgeMap(edgeMap, currentCity);
            i++;
        }

        //--- Create 2. child
        //--- Build edge map
        edgeMap = buildEdgeMap(this.genes, mate.genes);
        //--- Initialize list of available cities
        for(i = 0; i < genes.length; i++)
            availableCities.add(new Integer(i));
        //--- Construct a new tour by using the edge map
        i = 0;
        currentCity = generator.nextInt(genes.length);    //--- start from randomly chosen city
        children[1].genes[i] = currentCity;                         //--- add currentCity to the constructed tour
        availableCities.remove(Integer.valueOf(currentCity)); //--- update list of available cities
        updateEdgeMap(edgeMap, currentCity);                  //--- remove all occurences of the currentCity from the edgeMap
        i++;
        while(i < genes.length){
            currentCity = chooseNextCity(edgeMap, currentCity, availableCities);   //--- choose next city from the edgeMap
            children[1].genes[i] = currentCity;
            availableCities.remove(Integer.valueOf(currentCity));
            updateEdgeMap(edgeMap, currentCity);
            i++;
        }
        
        return children;
    }

    /**
     * Order crossover.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public TSPIndividual[] orderCrossover(TSPIndividual mate) {
        TSPIndividual[] children = new TSPIndividual[2];

        //--- TODO: PUT YOUR CODE HERE
        
        return children;
    }
    
    /**
     * Find proper crossover according settings in SGA.java file.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public TSPIndividual[] crossover(TSPIndividual mate) {
        switch (parameters.getCrossType()) {
            case 0:
                return edgeRecombinationCrossover(mate);
            case 1:
                return orderCrossover(mate);
            default:
                System.err.println("ERROR - Bad value of crossType variable.");
                System.exit(1);
                return null;
        }
    }
    
    public void mutate() {
        switch (parameters.getMutationType()) {
            case 0:
                moveMutation(); break;
            case 1:
                swapMutation(); break;
            default:
                System.err.println("ERROR - Bad value of mutationType variable.");
                System.exit(1);
        }
    }
    
    /**
     * Mutation - swap two randomly chosen cities.
     */
    public void swapMutation() {

        //--- TODO: PUT YOUR CODE HERE
        
    }

    /**
     * Mutation - moves one city right after another one.
     */
    public void moveMutation() {
        int count = 1 + generator.nextInt(5);  //--- number of swaps to be carried out
        int from, to, temp;

        //--- Carry out the mutation action counter times
        for (int i = 0; i < count; i++) {
            //--- choose 'from' and 'to' positions
            from = generator.nextInt(genes.length);
            do{
                to = generator.nextInt(genes.length);
            }while(from == to);
            //--- move a city at position 'from' to position 'to'
            if(from < to){
                temp = this.genes[from];
                for(int j = from; j < to; j++)
                    this.genes[j] = this.genes[j+1];
                this.genes[to] = temp;  //--- put there a city that was originally at position 'from' 
            }
            else{
                temp = this.genes[from];
                for(int j = from; j > to; j--)
                    this.genes[j] = this.genes[j-1];
                this.genes[to] = temp;  //--- put there a city that was originally at position 'from' 
            }
        }
    }
    
    /**
     * Checks whether the genes contain a valid tour through all cities.
     */
    public boolean checkValidity(){
        ArrayList<Integer> cities = new ArrayList<>();
        
        for(int i = 0; i < this.genes.length; i++)
            cities.add(new Integer(this.genes[i]));

        for(int i = 0; i < this.genes.length; i++)
            if(!cities.contains(Integer.valueOf(i)))
                return false;

        return true;
    }
}
