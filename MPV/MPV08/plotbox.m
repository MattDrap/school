function [h] = plotbox(bb, varargin)
%PLOTBOX - plots a bounding box
%
%  [h] = plotbox(bb, varargin)
%
%    bb - (4x1) [tlx, tly, brx, bry]
% 

% if isempty(varargin)
%      varargin = {'facealpha',0, 'edgecolor', 'b'};
% end
%h = fill([bb(1),bb(3), bb(3), bb(1)],[bb(2),bb(2), bb(4), bb(4)], 'b', varargin{:}); 

h = plot([bb(1), bb(3), bb(3), bb(1), bb(1)], [bb(2), bb(2), bb(4), bb(4), bb(2)], 'b');