function [vertex_cost, topleft_cost, top_cost, topright_cost] = ...
    seam_cost_forward2(img, mask_delete, mask_protect)
% Compute vertex costs for seam carving task. The edge costs are based on
% potentially carved pixels. The vertex costs ensure deletion or protection
% of the desired pixels.
%
% Input:
%   img [MxNx3 (double)] input RGB image
%   mask_delete [MxN (logical)] matrix specyfing pixels for which vertex
%     cost must be low enough to ensure their priority carving
%   mask_protect [MxN (logical)] matrix specyfing pixels for which vertex
%     cost must be low enough to ensure their priority carving
%
% Output:
%   vertex_cost [MxN (double)] vertex costs for individual pixels based on
%     the deletion and protection masks
%   topleft_cost [MxN (double)] topleft_cost(i,j) =
%     ||img(i,j+1) - img(i,j-1)|| + ||img(i-1,j) - img(i,j-1)|| for i>1 and
%     j=2..N-1; topleft_cost(i,N) = inf for i>1; topleft_cost(1,:) and
%     topleft_cost(:,1) are undefined
%   top_cost [MxN (double)] top_cost(i,j) = ||img(i,j+1) - img(i,j-1)|| for
%     i>1 and j=2..N-1; top_cost(i,1) = top_cost(i,N) = inf for i>1;
%     top_cost(1,:) are undefined
%   topright_cost [MxN (double)] topright_cost(i,j) =
%     ||img(i,j+1) - img(i,j-1)|| + ||img(i-1,j) - img(i,j+1)|| for i>1 and
%     j=2..N-1; topright_cost(i,1) = inf for i>1; topright_cost(1,:) and
%     topright_cost(:,N) are undefined

[h, w, ~] = size(img);
imgGray = rgb2gray(img);

% add code for computing topleft_cost, top_cost and topright_cost
sL0 = [0 1 0; 0 0 0];
sL1 = [0 0 0; 1 0 0];

sM0 = [0 0 0; 1 0 0];
sM1 = [0 0 0; 0 0 1];

sR0 = [0 1 0; 0 0 0];
sR1 = [0 0 0; 0 0 1];

convM0 = convn(img,sM0,'same');
convM1 = convn(img,sM1,'same');
d = convM1-convM0;
distM = sqrt(d(:,:,1).*d(:,:,1) + d(:,:,2).*d(:,:,2) + d(:,:,3).*d(:,:,3));

convL0 = convn(img,sL0,'same');
convL1 = convn(img,sL1,'same');
d = convL1-convL0;
distL = sqrt(d(:,:,1).*d(:,:,1) + d(:,:,2).*d(:,:,2) + d(:,:,3).*d(:,:,3));

convR0 = convn(img,sR0,'same');
convR1 = convn(img,sR1,'same');
d = convR1-convR0;
distR = sqrt(d(:,:,1).*d(:,:,1) + d(:,:,2).*d(:,:,2) + d(:,:,3).*d(:,:,3));

top_cost = distM;
topleft_cost = distM + distL;
topright_cost = distM + distR;
%top_cost = top_cost*2;

topleft_cost(:,w) = Inf;
%topleft_cost(1,:) = undefined;
%topleft_cost(:,1) = undefined;

top_cost(:,1) = Inf;
top_cost(:,w) = Inf;
%top_cost(1,:) = undefined;

topright_cost(:,1) = Inf;
%topright_cost(1,:) = undefined;
%topright_cost(:,w) = undefined;
           
% default vertex_cost is zero
vertex_cost = zeros(h, w);

if exist('mask_delete', 'var')
    vertex_cost(mask_delete == true)=-3.464101615137754587054892683011744733885610507620761256111613*(h-1);
end

if exist('mask_protect', 'var')
    vertex_cost(mask_protect == true)=3.464101615137754587054892683011744733885610507620761256111613*(h-1);
end
end

