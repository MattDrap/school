function xNew = track_demo(imgPrev,imgNew,xPrev,options)
%TRACK_DEMO example of writing tracking function
% Input:
%  imgPrev   previos frame of video sequence
%  imgNew    actual frame of video sequence
%  xPrev     tracking points in the previous frame
%  options   stucture with parameters for specific tracking method
% 
% Output:
%  xNew      tracking points in the actual frame

    % create coordinates vectors
    x = xPrev.x;
    y = xPrev.y;
    
    % example - constant movement defined in options
        x = x + options.demoMoveX;
        y = y + options.demoMoveY;
    
    % options.demoLose% of points are lost in this step
    detected = rand(length(x),1) > options.demoLose/100;
   
    % prepare export data structure
    xNew = struct('x',[],'y',[],'ID',[],'data',[]);        
    xNew.x = x(detected);
    xNew.y = y(detected);
    xNew.ID = xPrev.ID(detected);
    xNew.data = xPrev.data(detected);
end