function convolved = cnnConvolve(images, filters)
% Performs convolution on input layer
% INPUTS:
%   images: 4D feature maps
%   filters: 4D filters
% OUTPUTS:
%   convolved: 4D feature maps

imageDim = size(images, 1);
imageChannels = size(images, 3);
numImages = size(images, 4);
numFilters = size(filters, 4);
filterDim = size(filters,1);
convolvedDim = imageDim - filterDim + 1;

% Pre-allocate
convolved = zeros(convolvedDim, convolvedDim, numFilters, numImages, class(images));

for image = 1:numImages
    for filter = 1:numFilters
        convolvedImage = zeros(convolvedDim, convolvedDim, class(images));
        for channel = 1:imageChannels
            convolvedImage = convolvedImage + conv2(images(:, :, channel, image), filters(end:-1:1, end:-1:1, channel, filter), 'valid');            
        end
        convolved(:, :, filter, image) = convolvedImage;
    end
end


end

