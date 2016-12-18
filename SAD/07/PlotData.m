function PlotData(points,labels,titlestring)
% Plot the points into a 2D graph
%
% Input: 
%   points = coordinates of 2D points
%   labels = vector of 1s or 2s, which determines the cluster
%   titlestring = title of the graph

clf;
hold on;
title(titlestring);

plot(points(find(labels==1),1), points(find(labels==1),2), 'b*'); 
plot(points(find(labels==2),1), points(find(labels==2),2), 'ro');
