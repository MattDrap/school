function pooled = cnnPool(convolved, poolDim, pooling)
% Performs pooling on feature maps
% INPUTS:
%   convolved: 4D feature maps
%   poolDim: pooling dimension, p
%   pooling: 'max' for max pooling and 'mean' for mean pooling
% OUTPUTS:
%   pooled: 4D pooling layer

if nargin<3
    pooling='max';
end

numImages = size(convolved, 4);
numFeatures = size(convolved, 3);
convolvedDim = size(convolved, 1);

pooled = zeros(floor(convolvedDim / poolDim), floor(convolvedDim / poolDim), numFeatures, numImages);

if strcmp(pooling, 'max')
    for x = 1:(convolvedDim/poolDim)
        for y = 1:(convolvedDim/poolDim)
            pooled(x, y, :, :) = max(max(convolved(1+(x-1)*poolDim:x*poolDim, 1+(y-1)*poolDim:y*poolDim, :, :),[],1),[],2); % Max-pooling
        end
    end
elseif strcmp(pooling, 'mean')
    
    for x = 1:(convolvedDim/poolDim)
        for y = 1:(convolvedDim/poolDim)
            pooled(x, y, :, :) = mean(mean(convolved(1+(x-1)*poolDim:x*poolDim, 1+(y-1)*poolDim:y*poolDim, :, :))); % Mean-pooling
        end
    end
end


end

