function patches = samplePatches(I, patchDim, numPatches)
% Randomly sample numPatches patches with dimension patchDim x patchDim
% from the image I.

imageHeight = size(I,1);
imageWidth = size(I,2);
imageChannels = size(I,3);
numImages = size(I,4);

patches = zeros(patchDim * patchDim * imageChannels, numPatches);
for i=1:numPatches
    x = randi(imageWidth - patchDim + 1,1);
    y = randi(imageHeight - patchDim + 1,1);
    im = randi(numImages,1);
    patches(:,i) = reshape(I(y : y + patchDim - 1, x : x + patchDim - 1, :,im),[],1);
end

end

