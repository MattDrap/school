function eigvecs=CalcLaplacian(W, normalize)

% CalcLaplacian Calculates non-normalized Laplacian similarity matrix
%   At the same time, the eigenvectors are found and first 2 are returned

% Input:
%   W = similarity matrix, squared, symmetric, without negative values
% normalize = if Laplacian should be normalized
% normalize = 0 No normalization
% normalize = 1 Symmetric normalization
% normalize = 2 Random walk normalization

if(nargin == 1)
    normalize = 0;
end

if (size(W,1) ~= size(W,2))
  error('Matrix is not squared!')
end

% Find number of neighbours for each item
num_points=size(W,1);
d=zeros(num_points,1);
d=sum(W,2);
if(sum(d==0)>0) 
  disp('Warning: There is an isolated vertex without neighbours.'); 
  d(find(d==0)) = 1/num_points; 
end

if(normalize == 0)
% L = D - W
    L = (spdiags(d,0,num_points,num_points)-W);
end
if(normalize == 1)
     % Lsym = I - D^-1/2 * W * D^-1/2
        Dih = spdiags(1./sqrt(d),0,num_points,num_points);
        L = speye(num_points, num_points) - Dih*W*Dih;
end
if(normalize == 2)
        Di = spdiags(1./d,0,num_points,num_points);
        L = speye(num_points, num_points) - Di*W;
end
% Compute first 2 eigenvectors
[eigvecs,eigvals] = try_compute_eigvecs(L,2);
% The eig function is also possible, but less stable
% [V,E]=eig(L);
% eigvecs=V(:,1:2);



function [eigvecs, eigvals] = try_compute_eigvecs(A,num_eigvecs)
% Computes the eigenvectors and eigenvalues of A for spectral clustering


num_points = size(A,1);

% A should be symmetric, but due to small numerical errors this might
% not be the case. so force it to be symmetric: 
A = 0.5*(A+A');


try

  % want to look at each connected component of the graph individually.
  % Is numerically more stable if we compute the eigenvectors on the individual components. 
  % But we might end up computing more eigenvectors than absolutely necessary. 
  % 
  % Usually, spectral clustering is called on a connected graph anyway, then this 
  % whole connected component business is not important anyway. 
  
  % compute the connected components: 
  c = GD_GetComps(A);
  NumComps=max(c);
  
  % allocate result vectors: 
  % in each conneted component, we compute up to num_eigvecs eigenvectors:
  revecs=zeros(num_points, NumComps*num_eigvecs);
  revals=zeros(NumComps*num_eigvecs,1);
  
  
  % now go through all connected components and compute the eigenvalues/vectors:
  Counter=1;
  PtsPerComp = zeros(NumComps,1);
  for i=1:NumComps       
    % get points, labels, and adjacency matrix of connected component i: 
    Labels   = find(c==i);
    Rest     = find(c~=i);
    SubMatrix = A(Labels,Labels);
    PtsInComp = length(Labels);
    PtsPerComp(i) = PtsInComp;
    
    % now look at current connected component: 
    if(PtsInComp == 1)
      % if connected component consists of one point: trivial case, know that eigenvector is 1 and eigenvalue is 0.
      evecs=1;
      evals=0;
    else
      % compute the eigenvectors using eig (for small matrices) or eigs (for larger matrices):
      GD_options.disp=0;
      if(PtsInComp>200)
        [evecs,evals]=eigs(SubMatrix,num_eigvecs,'sa', GD_options);
      else
        [evecs,evals]=eig(full(SubMatrix));
      end
    end
    % number of eigenvalues computed. in case we used eig, this will be equal to PtsInComp, 
    % in case we used eigs this will be equal to min(num_eigvecs, PtsInComp)
    NrCompEig = size(evals,1);
    
    % assign eigenvalues in result vector: 
    extract = diag(evals);
    extract = extract(1:min(num_eigvecs,NrCompEig));
    revals(Counter:Counter+min(num_eigvecs,NrCompEig)-1) = extract;
    
    % assign eigenvectors in result vector: 
    % only use the first num_eigvecs ones
    for j=1:min(num_eigvecs,NrCompEig)
      revecs(Labels,Counter+j-1)=evecs(:,j);
    end
    Counter=Counter+min(num_eigvecs,NrCompEig);
  end
  
  % 
  revals=revals(1:Counter-1);
  revecs=revecs(:,1:Counter-1);
  
  % Sort eigenvalues by size
  [eigvals,IX]=sort(revals, 'ascend');
  eigvecs=revecs(:,IX);
  
  if(NumComps > 1) % in case we have more than one connected component we sort the zero eigenvectors by the number of points inside the component (large components first !)
   PtsPerComp = sum(abs(eigvecs(:,1:NumComps))>0,1);
   [PtsPerComp,IX]=sort(PtsPerComp,'descend');
   eigvals(1:NumComps)=eigvals(IX);
   eigvecs(:,1:NumComps)=eigvecs(:,IX);
  end
  
  % finally, pick the first num_eigvecs ones: 
  eigvals=eigvals(1:num_eigvecs);
  eigvecs=eigvecs(:,1:num_eigvecs);
  
catch 
  warning('Could not compute eigenvectors. Spectral clustering NaN')
  eigvecs = NaN; 
  eigvals = NaN;
end 

