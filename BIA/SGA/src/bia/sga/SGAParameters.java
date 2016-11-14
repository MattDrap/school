/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.sga;

import java.io.FileInputStream;
import java.util.Properties;

/**
 * Class POEMSProperties is an internal representation of the configuration
 * parameters of the algorithm poems. All parameters are read from the file
 * PoemsConf.properties.
 *
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class SGAParameters extends Properties {

    private String functionName; // fitness function class name
    private ContinuousFunction function = null; // fitness function
    private int genesPerValue = 16;      // chromosome size
    private double minX = 0.0;
    private double maxX = 50.0;
    private double rangeX = maxX - minX;
    private int popSize = 100;      // population size
    private int evaluations = 1000; // number of fitness evaluations
    private int crossType = 0;      // crossover type: 0 ... uniform, 1 ... 1-point, 2 ... 2-point
    private double pC = 0.75;       // crossover probability
    private double pM = 0.02;       // mutation probability
    private int selectionType = 0;  // selection type: 0 ... tournament selection
    private int tournamentSize = 3; // tournament size parameter
    private int replacementType = 0;// replacement strategy type: 0 ... generational, 1 ... steady-state
    //---
    private static SGAParameters instance;

    /**
     * Private constructor.
     */
    private SGAParameters() {
//        functionName = "bia.sga.ExampleFunction";
    }

    /**
     * Class SGAParameters is an implementation of singleton design pattern.
     * This method returns the instance of this class.
     *
     * @return instance of class SGAParameters
     */
    public static SGAParameters getInstance() {
        if (instance == null) {
            instance = new SGAParameters();
        }
        return instance;
    }

    /**
     * This method will read the configuration file and set the values for the
     * POEMS run.
     */
    public void readConfigFile() throws Exception {

        FileInputStream fis = new FileInputStream("SGAConfiguration.properties");
        this.load(fis);

        try {
            functionName = this.getProperty("function");
        } catch (Exception e) {
            System.out.println("Uses default functionName solution.bia.sga.ExampleFunction");
        }
        try {
            popSize = Integer.parseInt(this.getProperty("popSize"));
        } catch (Exception e) {
            System.out.println("Uses default popSize");
        }
        try {
            genesPerValue = Integer.parseInt(this.getProperty("genesPerValue"));
        } catch (Exception e) {
            System.out.println("Uses default genesPerValue");
        }
        try {
            minX = Double.parseDouble(this.getProperty("minX"));
        } catch (Exception e) {
            System.out.println("Uses default minX");
        }
        try {
            maxX = Double.parseDouble(this.getProperty("maxX"));
        } catch (Exception e) {
            System.out.println("Uses default maxX");
        }
        rangeX = maxX - minX;

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

        if (popSize <= 4) {
            throw new Exception("check configuration: popSize must be greater than 4");
        }
        if (genesPerValue < 4) {
            throw new Exception("check configuration: genesPerValue must be greater than 4");
        }
        if (minX >= maxX) {
            throw new Exception("check configuration: minX must be smaller than maxX");
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

        Class c = Class.forName(functionName);
        function = (ContinuousFunction) c.newInstance();
    }

    public String getFunctionName() {
        return functionName;
    }

    public ContinuousFunction getFunction() {
        return function;
    }

    public int getPopSize() {
        return popSize;
    }

    public int getGenesPerValue() {
        return genesPerValue;
    }

    public double getMinX() {
        return minX;
    }

    public double getMaxX() {
        return maxX;
    }

    public double getRangeX() {
        return rangeX;
    }

    public int getEvaluations() {
        return evaluations;
    }

    public int getCrossType() {
        return crossType;
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

    public int getTournamentSize() {
        return tournamentSize;
    }
}
