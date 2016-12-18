function S=CalcSimMatrix(points,sigma)
% Generate the similarity matrix using the Euclidian distance and a Gaussian kernel
%
% S=CalcSimMatrix(points,sigma) calcualte the similarity matrix
% S=CalcSimMatrix(points) calculate with variance = 0.5
%
% Input:
%   points = coordinates of points in a 2D space
%   sigma = Gaussovskeho noise, variance within a cluster

switch(nargin)
  case 0, error('Chybi souradnice datovych bodu.');
  case 1, sigma=0.5;
end

D=DistEuclidean(points,points);
S = exp(- D / (2 * sigma^2));



function D = DistEuclidean(X,Y)
  
  if( ~isa(X,'double') || ~isa(Y,'double'))
      error( 'Arguments must be of type double.');
  end;
  
  m = size(X,1); n = size(Y,1);  
  Yt = Y';  
  XX = sum(X.*X,2);        
  YY = sum(Yt.*Yt,1);      
  D = XX(:,ones(1,n)) + YY(ones(1,m),:) - 2*X*Yt;
  