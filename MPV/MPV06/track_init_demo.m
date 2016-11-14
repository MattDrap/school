function xOut = track_init_demo(img,options)
%TRACK_INIT example of tracking point initialization
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
    
    % find points 
    
        % example - place options.demoNumPoints random points intto the ROI
        
        x = ROI(1) + ceil(rand(options.demoNumPoints,1)*ROI(3));
        y = ROI(2) + ceil(rand(options.demoNumPoints,1)*ROI(4));
        data = repmat(struct('annotation','demoPoint'),[options.demoNumPoints,1]);
    
    % prepare export data structure
    xOut = struct('x',[],'y',[],'ID',[],'data',[]);        
    xOut.x  = x;
    xOut.y  = y;
    xOut.ID = (1:length(x))';     % for unique identification of the point
    xOut.data = data;             % some your information about points (SIFT etc.)
end
     