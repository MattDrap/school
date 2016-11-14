function xOut = track_init_correspond(img,options)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% Input:
%  img      image to find tracking points
%  options  stucture with parameters for specific detecting method
% 
% Output:
%  xOut     tracking points found in the input image

    % ROI=[XOffset YOffset Width Height]
    ROI = options.ROI;
    
    % create region of interest 
    crop = img(ROI(2)+1:ROI(2)+ROI(4),ROI(1)+1:ROI(1)+ROI(3));
    
    
    [x,y]=harris(img, options.sigmad, options.sigmai, options.threshold);
    pts = transnorm(img, x, y, 25, options);
    
    pts = photonorm(pts);
    for i=1:numel(pts)
        pts(i).desc = dctdesc(pts(i).patch, options.num_coeffs);
    end
    
    xOut = struct('x',[],'y',[],'ID',[],'data',[]);        
    xOut.x  = x';
    xOut.y  = y';
    xOut.ID = (1:length(x))';     % for unique identification of the point
    xOut.data = pts;             % some your information about points (SIFT etc.)
    
end

