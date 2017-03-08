function patches = image2patches(image, convolvedDim, stepsize)
% Image->Patches

if nargin < 3
    stepsize = 1;
end

nx = size(image, 1)-convolvedDim+1;
imageChannels = size(image, 3);
numImages = length(1:stepsize:nx)^2;

patches = zeros(convolvedDim, convolvedDim, imageChannels, numImages, class(image));
i = 1;
for x=1:stepsize:nx
    for y=1:stepsize:nx
        %patches(:,:,:,i) = image(1+(y-1)*convolvedDim:y*convolvedDim, 1+(x-1)*convolvedDim:x*convolvedDim,:);
        patches(:,:,:,i) = image(y:y+convolvedDim-1,x:x+convolvedDim-1,:);
        i = i + 1;
    end
end

end
