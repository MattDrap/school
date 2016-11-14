%clear all;

%options.demoLose = 5;
%options.demoMoveX = 5;
%options.demoMoveY = 3;
%options.demoNumPoints = 20;
% ROI=[XOffset YOffset Width Height]
%options.ROI = [20 20 50 30];    

%processMpvVideo('.\avi\billa_xvid.avi','demo',options)
clear all;

options.ps = 10;
options.ext = 10;
options.num_coeffs = 10;

options.sigmad = 1.0;
options.sigmai = 1.0;
options.threshold = 0.03^4;
options.rnsc_threshold = 5;
options.rnsc_confidence = 0.99;
% ROI=[XOffset YOffset Width Height]
options.ROI = [20 20 50 30];    

processMpvVideo('.\avi\billa_xvid.avi','correspond',options)