/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.tsp;

import java.io.FileInputStream;
import java.util.Properties;

/**
 * Class POEMSProperties is an internal representation of the configuration
 * parameters of the algorithm poems. All parameters are read from the file
 * PoemsConf.properties.
 *
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class TSPParameters extends Properties {

    private String dataset;
    private int popSize = 1000;      // population size
    private int evaluations = 100000; // number of fitness evaluations
    private int crossType = 0;      // crossover type: 0 ... edge recombination, 1... order x-over
    private int mutationType = 0;   // mutation type: 0...move, 1...swap
    private double pC = 0.8;       // crossover probability
    private double pM = 0.25;       // mutation probability
    private int selectionType = 0;  // selection type
    private int tournamentSize = 7; // tournament size parameter
    private int replacementType = 1;// replacement strategy type
    private int initializationType = 0;// initialization strategy: 0...random, 1...nearest neighbor
    private boolean visualization = false;// 1...On, 0...Off
    //---
    private static TSPParameters instance;

    /**
     * Private constructor.
     */
    private TSPParameters() {
    }

    /**
     * Class SGAParameters is an implementation of singleton design pattern.
     * This method returns the instance of this class.
     *
     * @return instance of class SGAParameters
     */
    public static TSPParameters getInstance() {
        if (instance == null) {
            instance = new TSPParameters();
        }
        return instance;
    }

    /**
     * This method will read the configuration file and set the values for the
     * POEMS run.
     */
    public void readConfigFile() throws Exception {

        FileInputStream fis = new FileInputStream("TSPConfiguration.properties");
        this.load(fis);

        try{
            dataset = this.getProperty("dataset");
        } catch (Exception e) {
            System.err.println("Input file not defined!");
        }
        if (dataset == null || dataset.equals("")) {
            throw new Exception("check configuration: configvalue: dataset must be defined");
        }

        try {
            popSize = Integer.parseInt(this.getProperty("popSize"));
        } catch (Exception e) {
            System.out.println("Uses default popSize");
        }
        try {
            evaluations = Integer.parseInt(this.getProperty("evaluations"));
        } catch (Exception e) {
            System.out.println("Uses default evaluations");
        }
        try {
            crossType = Integer.parseInt(this.getProperty("crossType"));
        } catch (Exception e) {
            System.out.println("Uses default crossType");
        }
        try {
            mutationType = Integer.parseInt(this.getProperty("mutationType"));
        } catch (Exception e) {
            System.out.println("Uses default mutationType");
        }
        try {
            pC = Double.parseDouble(this.getProperty("pC"));
        } catch (Exception e) {
            System.out.println("Uses default pC");
        }
        try {
            pM = Double.parseDouble(this.getProperty("pM"));
        } catch (Exception e) {
            System.out.println("Uses default pM");
        }
        try {
            selectionType = Integer.parseInt(this.getProperty("selectionType"));
        } catch (Exception e) {
            System.out.println("Uses default selectionType");
        }
        try {
            tournamentSize = Integer.parseInt(this.getProperty("tournamentSize"));
        } catch (Exception e) {
            System.out.println("Uses default tournamentSize");
        }
        try {
            replacementType = Integer.parseInt(this.getProperty("replacementType"));
        } catch (Exception e) {
            System.out.println("Uses default replacementType");
        }
        try {
            initializationType = Integer.parseInt(this.getProperty("initializationType"));
        } catch (Exception e) {
            System.out.println("Uses default initializationType");
        }
        try {
            visualization = Boolean.parseBoolean(this.getProperty("visualization"));
        } catch (Exception e) {
            System.out.println("Uses default visualization");
        }
                
        if (popSize <= 4) {
            throw new Exception("check configuration: popSize must be greater than 4");
        }
        if (evaluations < popSize) {
            throw new Exception("check configuration: evaluations must be greater or equal than popSize");
        }
        if ((crossType < 0) || (crossType > 2)) {
            throw new Exception("check configuration: crossType must be either 0 or 1 or 2");
        }
        if ((pC < 0.0) || (pC > 1.0)) {
            throw new Exception("check configuration: crossover probability must be within (0.0, 1.0)");
        }
        if ((pM < 0.0) || (pM > 1.0)) {
            throw new Exception("check configuration: mutation probability must be within (0.0, 1.0)");
        }
        if (tournamentSize <= 0) {
            throw new Exception("check configuration: tournamentSize must be greater than 0");
        }
    }

    public int getPopSize() {
        return popSize;
    }

    public int getEvaluations() {
        return evaluations;
    }

    public int getCrossType() {
        return crossType;
    }

    public int getMutationType() {
        return mutationType;
    }
    
    public double getPC() {
        return pC;
    }

    public double getPM() {
        return pM;
    }

    public int getSelectionType() {
        return selectionType;
    }

    public int getReplacementType() {
        return replacementType;
    }
    
    public int getInitializationType() {
        return initializationType;
    }
    
    public boolean getVisualization() {
        return visualization;
    }
        
    public int getTournamentSize() {
        return tournamentSize;
    }
    
    public String getDataset() {
        return dataset;
    }
}
