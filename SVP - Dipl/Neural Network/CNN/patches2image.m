function image = patches2image(patches)
% Patches->Image

imageDim = size(patches, 1);
imageChannels = size(patches, 3);
nx = sqrt(size(patches,4));
assert(mod(nx,1)==0, 'patches2image: Number of patches is not a square number')

image = zeros(imageDim*nx, imageDim*nx, imageChannels, class(patches));
i = 1;
for x=1:nx
    for y=1:nx
        image(1+(y-1)*imageDim:y*imageDim, 1+(x-1)*imageDim:x*imageDim,:) = patches(:,:,:,i);
        i = i + 1;
    end
end

end