/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bia.tsp;

import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import javax.swing.JFrame;
import java.io.*;

/**
 *
 * @author Frantisek Hruska
 */
public class TSPviz extends Canvas {

		  public static Node[] nodes;		 // Cities
		  public static int N;	  // Number of cities
		  public static double maxX = Double.MIN_VALUE;	  // Maximal X-position from all cities
		  public static double minX = Double.MAX_VALUE;	  // Minimal X-position from all cities
		  public static double maxY = Double.MIN_VALUE;	  // Maximal Y-position from all cities
		  public static double minY = Double.MAX_VALUE;	  // Minimal Y-position from all cities
		  public static double multCoefX;				// Just coeficient to fit instance into window.
		  public static double multCoefY;				// Just coeficient to fit instance into window.
		  public static int frameSize = 600;		// Size of graphic window.
		  public static int circleSize = 4;			// Size of the circle marker for cities.
		  /**
		   * @param args the command line arguments
		   */
		  public static void main(String[] args) {
					 String fileName = "TSP.txt";
					 if (fileName == null) {
								return;
					 }

					 // Init graphics
					 TSPviz TSP = new TSPviz();  

                     // Load cities.
					 String line;
					 // read the lines out of the file
					 try {
								BufferedReader input = new BufferedReader(new FileReader(fileName));
								try {
										  line = input.readLine();
										  N = Integer.parseInt(line);
										  nodes = new Node[N];
										  for (int i = 0; i < N; i++) {
													 line = input.readLine();
													 String[] s = line.split("\\s");
													 nodes[i] = new Node(Double.parseDouble(s[0]), Double.parseDouble(s[1]));
													 if(Double.parseDouble(s[0]) < minX) minX = Double.parseDouble(s[0]);
													 if(Double.parseDouble(s[0]) > maxX) maxX = Double.parseDouble(s[0]);
													 if(Double.parseDouble(s[1]) < minY) minY = Double.parseDouble(s[1]);
													 if(Double.parseDouble(s[1]) > maxY) maxY = Double.parseDouble(s[1]);
										  }
								} catch (IOException IOE) {
										  System.err.println("Bad format of the file!");
										  System.exit(1);
								}
					 } catch (FileNotFoundException FNFE) {
								System.err.println("File " + fileName + " not found!");
								System.exit(1);
					 }
					 
					 // Get coeficient for better drawing.
					 multCoefX = frameSize / Math.abs(maxX - minX);
					 multCoefY = frameSize / Math.abs(maxY - minY);
					 
					 //create a new frame to which we will add a canvas
					 JFrame aFrame = new JFrame();
					 //aFrame.setAction(JFrame.EXIT_ON_CLOSE);
					 aFrame.setSize(frameSize, frameSize);
					 aFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

                     //add the canvas
					 aFrame.add(TSP);

					 aFrame.setVisible(true);
		  }

		  public TSPviz() {

					 setSize(frameSize, frameSize);
					 setBackground(Color.WHITE);
		  }

          
		  public void paint(Graphics g) {
              int offset = 10;

                Graphics2D g2d = (Graphics2D) g;

                // Draw the depot with red color and two circles.
                // Constructor for Ellipse2D is X,Y,W,H and X,Y is upper corner of bounding box for Ellipse2D, 
                // so there shoud be that half of its diameter (W,H) substracted from X and Y
                g2d.setColor(Color.red);
                double dX, dY;
                // Adjust coordinates to window.
                dX = offset + (nodes[0].x-minX) * multCoefX; // + frameSize/2;
                dY = offset + (nodes[0].y-minY) * multCoefY; // + frameSize/2;
                Ellipse2D.Double depot = new Ellipse2D.Double(dX - circleSize, dY - circleSize, 2*circleSize, 2*circleSize);
                g2d.fill(depot);

                g2d.setColor(Color.red);
                for (int i = 1; i < N; i++) {
                    // Adjust coordinates to window.
                    double x = offset + (nodes[i].x-minX) * multCoefX; // + frameSize/2;
                    double y = offset + (nodes[i].y-minY) * multCoefY; // + frameSize/2;
                    // Again bounding box for ellipse.
                    Ellipse2D.Double city = new Ellipse2D.Double(x-circleSize, y-circleSize, 2*circleSize, 2*circleSize);
                    g2d.fill(city);
                }

                double x1, x2, y1, y2;
                g2d.setColor(Color.blue);
                for (int i = 0; i < N-1; i++) {
                    // Adjust coordinates to window.
                    x1 = offset + (nodes[i].x-minX) * multCoefX; // + frameSize/2;
                    y1 = offset + (nodes[i].y-minY) * multCoefY; // + frameSize/2;
                    x2 = offset + (nodes[i+1].x-minX) * multCoefX; // + frameSize/2;
                    y2 = offset + (nodes[i+1].y-minY) * multCoefY; // + frameSize/2;

                    g2d.draw(new Line2D.Double(x1, y1, x2, y2));
                }
                // Adjust coordinates to window.
                x1 = offset + (nodes[N-1].x-minX) * multCoefX; // + frameSize/2;
                y1 = offset + (nodes[N-1].y-minY) * multCoefY; // + frameSize/2;
                x2 = offset + (nodes[0].x-minX) * multCoefX; // + frameSize/2;
                y2 = offset + (nodes[0].y-minY) * multCoefY; // + frameSize/2;

                g2d.draw(new Line2D.Double(x1, y1, x2, y2));
          }
}
