function data = processMpvInit(img, options);

%TRACK_INIT example of tracking point initialization
% Input:
%  img      image to find tracking points
%  options  stucture with parameters for specific detecting method
% 
% Output:
%  data     marked rectangle

    % select a rectangle in the image (by hand)
    [imgCrop rect] = imcrop(img);

    % trasform the coordinates - [x y w h] -> x and y vector of each corner
    data.xRect = [rect(1) rect(1)         rect(1)+rect(3) rect(1)+rect(3)];
    data.yRect = [rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)        ];
    
end