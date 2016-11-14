/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.sga;

import static bia.sga.SGA.parameters;

/**
 * @author Frantisek Hruska, Jiri Kubalik
 */
public class Individual {

    /**
     * Genes of individual binary represented .
     */
    public int[] genes;

    /**
     * Fitness of individual.
     */
    public double fitness;

    /**
     * SGA parameters
     */
    public static SGAParameters parameters = SGAParameters.getInstance();

    /**
     * Constructor. Generates random individual.
     */
    public Individual() {
    
        // Allocate memory for genes array.
        genes = new int[getNumberOfGenes()];
        
        // Randomly initialise genes of individual.
        for (int genIter = 0; genIter < genes.length; genIter++) {
            if (Math.random() < 0.5) genes[genIter] = 0;
            else genes[genIter] = 1;
        }
        
        // Sampling bad regions of the search space for the ExampleFunction
        for(int i = genes.length/2; i < genes.length; i++)
            genes[i] = 0;   // set the most significant genes to 0
    }

    /**
     * Constructor generating empty individual without its genes defined.
     *
     * @param b dump parameter.
     */
    public Individual(boolean b) {
        // Only allocate memory for genes array.
        this.genes = new int[getNumberOfGenes()];
    }

    public int getNumberOfGenes() {
        return parameters.getGenesPerValue() * parameters.getFunction().getDimension();
    }

    /**
     * Cloning method for creating deep copies of individual instances.
     *
     * @return
     */
    @Override
    public Individual clone() {
        Individual copy = new Individual(false);
        copy.genes = new int[this.genes.length];
        System.arraycopy(this.genes, 0, copy.genes, 0, this.genes.length);
        copy.fitness = this.fitness;

        return copy;
    }

    /**
     * Decodes genotype stored in 'genes'.
     *
     * @return an integer values coded by a binary vector of genes
     */
    public double[] decodeGenes() {
        double[] phenotype = new double[parameters.getFunction().getDimension()];

        int cnt = 0;
        for (int i = 0; i < phenotype.length; i++) {
            int power = 1;
            double tmp = 0.0;
            for (int j = 0; j < parameters.getGenesPerValue(); j++) {
                tmp += (power * this.genes[cnt++]);
                power *= 2;
            }
            phenotype[i] = tmp;
        }
        return phenotype;
    }

    /**
     * Normalizes genotype stored in 'genes'.
     */
    public double[] normalizeX(double[] x) {
        double[] y = new double[x.length];

        for (int i = 0; i < x.length; i++) {
            double tmp = Math.pow(2.0, parameters.getGenesPerValue()) - 1.0;

            // Normalize x to interval defined by SGA.minX adn
            y[i] = parameters.getMinX() + (x[i] / tmp) * parameters.getRangeX();
        }
//        System.out.println("[" + Utils.vectorToString(y) + "]");
        return y;
    }

    /**
     * Fitness function calculation.
     */
    public void getFitness() {
        double[] x;

        // Decode parameter x
        x = this.decodeGenes();

        // Normalize value x into [SGA.minX, SGA.maxX] 
        x = this.normalizeX(x);

        // Calculate f(x)
        this.fitness = parameters.getFunction().f(x);
    }

    /**
     * One point crossover.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public Individual[] one_point_crossover(Individual mate) {
        Individual[] I = new Individual[2];
        // Make clones of this and input individual.
        I[0] = this.clone();
        I[1] = mate.clone();

        // Generate crosspoint.
        int cross_point = (int) (Math.random() * (getNumberOfGenes() - 1));

        // Crossing method.
        // Switch first part of chromozomes.
        for (int i = 0; i <= cross_point; i++) {
            I[0].genes[i] = mate.genes[i];
            I[1].genes[i] = this.genes[i];
        }
        // Copy rest of chromozomes.
        for (int i = cross_point + 1; i < getNumberOfGenes(); i++) {
            I[0].genes[i] = this.genes[i];
            I[1].genes[i] = mate.genes[i];
        }

        return I;
    }

    /**
     * One point crossover.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public Individual[] two_point_crossover(Individual mate) {
        Individual[] I = new Individual[2];
        // Make clones of this and mate individual.
        I[0] = this.clone();
        I[1] = mate.clone();

        // Generate crosspoints.
        int left_point = (int) (Math.random() * (getNumberOfGenes()));
        int right_point = left_point;
        // While both cross points are the same, generate new cross point.
        while (left_point == right_point) {
            right_point = (int) (Math.random() * (getNumberOfGenes()));
        }
        // Switch both cross point so the right_point is larger than the left_point.
        if (right_point < left_point) {
            int temp = left_point;
            left_point = right_point;
            right_point = temp;
        }

        // Copy first part of chromozomes.
        for (int i = 0; i <= left_point; i++) {
            I[0].genes[i] = this.genes[i];
            I[1].genes[i] = mate.genes[i];
        }
        // Switch middle parts of chromozomes.
        for (int i = left_point + 1; i <= right_point; i++) {
            I[0].genes[i] = mate.genes[i];
            I[1].genes[i] = this.genes[i];
        }
        // Copy rest of chromozomes.
        for (int i = right_point + 1; i < getNumberOfGenes(); i++) {
            I[0].genes[i] = this.genes[i];
            I[1].genes[i] = mate.genes[i];
        }

        return I;
    }

    /**
     * Uniform crossover. Each gene is switched under some probability value.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public Individual[] uniform_crossover(Individual mate) {

        Individual[] I = new Individual[2];
        // Make clones of this and input individual.
        I[0] = this.clone();
        I[1] = mate.clone();

        // Each gene is inherited either from the 1st or the 2nd parent
        for (int geneIter = 0; geneIter < getNumberOfGenes(); geneIter++) {
            if (Math.random() < 0.5)
                I[0].genes[geneIter] = mate.genes[geneIter];
            else
                I[0].genes[geneIter] = this.genes[geneIter];

            if (Math.random() < 0.5)
                I[1].genes[geneIter] = this.genes[geneIter];
            else
                I[1].genes[geneIter] = mate.genes[geneIter];
        }

        return I;
    }

    /**
     * Find proper crossover according settings in SGA.java file.
     *
     * @param mate second individual in crossover
     * @return newly generated individuals
     */
    public Individual[] crossover(Individual mate) {
        switch (parameters.getCrossType()) {
            case 0:
                return uniform_crossover(mate);
            case 1:
                return one_point_crossover(mate);
            case 2:
                return two_point_crossover(mate);
            default:
                System.err.println("ERROR - Bad value of crossType variable. Check if its value is between 0 and 2.");
                System.exit(1);
                return null;
        }
    }

    /**
     * Simple bit-flip mutation.
     */
    public void mutation() {

        for (int geneIter = 0; geneIter < getNumberOfGenes(); geneIter++) {
            // Mutate each gene with probability Pm
            if (Math.random() < parameters.getPM()) {
                if (genes[geneIter] == 1) 
                    genes[geneIter] = 0;
                else 
                    genes[geneIter] = 1;
            }
        }
    }
    
    /**
     * Compares this.fitness with ind.fitness and returns true if this.fitness is better than ind.fitness
     * according to the given problem (which can be either maximization or minimization).
     * @param ind
     * @return 
     */
    public boolean betterThan(Individual ind){
        
        if(parameters.getFunction().maximize()){
            // it is a maximization problem
            if(this.fitness > ind.fitness)
                return true;
            else
                return false;
        }
        else{
            // it is a minimization problem
            if(this.fitness < ind.fitness)
                return true;
            else
                return false;
        }
    }
}
