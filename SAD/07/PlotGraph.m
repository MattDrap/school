function PlotGraph(points,A,titlestring)
% Plots the similarity graph, unweighted.
% All points with non-zero similarity are connected.
%
% Input: 
%   points = coordinates of 2D points
%   A = similarity matrix, squared, symmetric, without negative values
%   titlestring = title of the graph 

% kontrola vstupu 
num_points = size(A,1); 

if (size(A,1) ~= size(A, 2)), 
  error('Matice sousednosti neni ctvercova. ')
end

if (sum(sum(A - A') > 0.0001)), 
  warning('Matice sousednnosti neni symetricka. Bude pouzita pouze jedna z orientaci')
end

if (size(points,1) ~= num_points)
  error('Pocet datovych bodu se neshoduje s dimenzi matice sousednosti.' )
end

% vykresli body
clf
hold all
plot(points(:,1), points(:,2), 'bx');


% vykresli hrany: 
xx = zeros(2*num_points,1);
yy = zeros(2*num_points,1);
DiffVal=0; NumDiffVal=0;
%tic
for it= 1: num_points
  indices = find(A(it,:)>0);
  NumIndices=length(indices);
  if(NumIndices>0)
    xx(1:2:2*NumIndices)=points(it,1);
    xx(2:2:2*NumIndices)=points(indices,1);
    yy(1:2:2*NumIndices)=points(it,2);
    yy(2:2:2*NumIndices)=points(indices,2);
    plot(xx(1:2*NumIndices),yy(1:2*NumIndices),'-r');
  end    
end

title(titlestring)
axis tight


