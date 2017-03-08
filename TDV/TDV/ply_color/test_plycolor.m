%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% example for coloring PLY files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uses ply functions by Pascal Getreuer
% modified by R.Tylecek, tylecr1@cmp.felk.cvut.cz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read
[tri, pts] = plyread('psr.ply','tri');

% colorize vertices using their coordinates in bounding box
col = zeros(size(pts));
for c=1:3
    col(:,c) = 255*(pts(:,c)-min(pts(:,c))) / max(pts(:,c)-min(pts(:,c)));
end

% save the result with color
plywritetricol(tri,pts,col,'psr_col.ply');
