clear all;

options.ps = 10;
options.ext = 10;
options.num_coeffs = 10;

options.sigmad = 1.0;
options.sigmai = 1.0;
options.threshold = 0.03^4;
options.rnsc_threshold = 5;
options.rnsc_confidence = 0.99;
options.klt_window = 10;         % size of patch W(x,p) in the sense of getPatchSubpix.m
options.klt_stop_count = 10;     % maximal number of iteration steps
options.klt_stop_treshold = 0.1;  % minimal change epsilon^2 for termination (squared for easier computation of the distance)
options.klt_show_steps = 0;     % 0/1 turning on and of drawing during tracking

processMpvVideo('.\avi\billa_xvid.avi','klt',options)