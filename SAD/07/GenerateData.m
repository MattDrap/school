function [x,y]=GenerateData(num,classProb,variance)
% Generates input data in a 2D space.
%
% Input:
%   num = total number of datapoints (default is 100)
%   classProb = 2D vector of probabilities for each point being in one of the clusters (default is [0.5 0.5])
%   variance = variance of Gaussian noise for generating randomness (default is 0.04)

switch(nargin)
  case 0, num=100; classProb=[0.5,0.5]; variance=0.04;
  case 1, classProb=[0.5,0.5]; variance=0.04;
  case 2, variance=0.04;
end

if (length(classProb)~=2)
  error('The classProb vector does not have size = 2.');
end

if(sum(classProb)~=1)
  warning('Sum of probabilities in classProb is not 2.');
  if(sum(classProb)~=0)
    classProb=classProb/sum(classProb);
  else
    classProb=[0.5,0.5];
  end
end

num = floor(num);
pos = rand(num,1);
numPtsClasses=zeros(1,2);
numPtsClasses(1)=sum(pos >= 0 & pos<classProb(1));
numPtsClasses(2)=sum(pos >= sum(classProb(1)) & pos<sum(classProb(1:2)));  
  
% Generate!
y=zeros(num,1);
num_pos=numPtsClasses(1); num_neg=numPtsClasses(2);
radii=ones(num,1);
phi  =rand(num_pos+num_neg,1).*pi;          

% Two half-moons.
x=zeros(num,2);
for i=1:num_pos
  x(i,1)=radii(i)*cos(phi(i));
  x(i,2)=radii(i)*sin(phi(i));
  y(i,1)=1;
end
for i=num_pos+1:num_neg+num_pos
  x(i,1)=1+radii(i)*cos(phi(i));
  x(i,2)=-radii(i)*sin(phi(i))+0.5;
  y(i,1)=2;
end
% pridej sum 
x=x + sqrt(variance)*randn(num,2);
display(['Number of points in cluster 1: ',num2str(numPtsClasses(1)),'; in cluster 2: ',num2str(numPtsClasses(2))]);
          