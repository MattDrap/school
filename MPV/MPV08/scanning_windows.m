function [bboxes, pos] = scanning_windows(img, min_size, stride, scale_factor)
%SCANNING_WINDOWS - generate scanning window bounding boxes 
%
%  [bboxes, pos] = scanning_windows(img, min_size, stride, scale_factor);
%
% 	       img - input image
%     min_size - minimum size of the scanning window [px] (square bbox) 
%       stride - stride of scanning [px] (note that higher levels are supposed to have stride multiplied by the scale_factor)
% scale_factor - next level upscaling 
%
%	
%       bboxes - corresponding bounding boxes (4xn) [tlx, tly, brx, bry]
%                (top left x-coordinate, ..., bottom right y-coordinate)
%       
%          pos - row, col, level (3xn) 
%                 row - 1..max number of scanning windows in rows
%                 col - 1..max number of scanning windows in columns
%               level - 1..max number of multiscale levels
%                    
[Height, Width, Color] = size(img);
pos = [];
bboxes = [];
counterL = 1;
nstop = true;
while nstop
    added = false;
    counterY = 1;
    for i = 1:stride:Height-min_size
        counterX = 1;
        for j = 1:stride:Width-min_size
            bboxes = [bboxes, [j;i;j+min_size;i+min_size]];
            pos = [pos, [counterY; counterX; counterL]];
            counterX = counterX + 1;
            added = true;
        end
        counterY = counterY + 1;
    end
    if ~added
        nstop = false;
    end
    counterL = counterL + 1;
    min_size = floor(min_size * scale_factor);
    stride = floor(stride * scale_factor);
end