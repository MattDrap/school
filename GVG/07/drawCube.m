function [] = drawCube( cubeProj, img )
if nargin < 2
    cubeProj = round(cubeProj);
    plot([cubeProj(1,1), cubeProj(1,2)], [cubeProj(2,1), cubeProj(2,2)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,2), cubeProj(1,3)], [cubeProj(2,2), cubeProj(2,3)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,3), cubeProj(1,4)], [cubeProj(2,3), cubeProj(2,4)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,4), cubeProj(1,1)], [cubeProj(2,4), cubeProj(2,1)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,5), cubeProj(1,6)], [cubeProj(2,5), cubeProj(2,6)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,6), cubeProj(1,7)], [cubeProj(2,6), cubeProj(2,7)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,7), cubeProj(1,8)], [cubeProj(2,7), cubeProj(2,8)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,8), cubeProj(1,5)], [cubeProj(2,8), cubeProj(2,5)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,1), cubeProj(1,5)], [cubeProj(2,1), cubeProj(2,5)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,2), cubeProj(1,6)], [cubeProj(2,2), cubeProj(2,6)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,3), cubeProj(1,7)], [cubeProj(2,3), cubeProj(2,7)], 'b', 'lineWidth', 2);
    plot([cubeProj(1,4), cubeProj(1,8)], [cubeProj(2,4), cubeProj(2,8)], 'b', 'lineWidth', 2);
end
end
