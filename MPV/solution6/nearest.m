function [I M]=nearest(means, data)
   
   num_data  = size(data,2);   
   M = ones(1, num_data, 'single')*inf;
   I = zeros(1, num_data);
   
   for i=1:size(means,2)
      D = sum((repmat(means(:,i), 1, num_data) - data).^2);
      idxs = D<M;
      M(idxs) = D(idxs);
      I(idxs) = i;
   end;
