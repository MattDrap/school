function plotpoints( data, name, colors )
% PLOTPOINTS plots 2D points with a Voronoi diagram, labels and colors
%
% plotpoints(data, name, colors)
%
% data ... Nx2 matrix with N samples (additional dimensions are ignored)
% name ... Nx1 cell-array with strings to be printed next to each point
% colors ... Nx1 matrix with numbers representing colors of the labels

    if (nargin < 3)
        colors = ones(size(data,1),1);
    end

    voronoi(data(:,1), data(:,2));
    hold on
    gscatter(data(:,1), data(:,2), colors);
    
    for i = 1:size(name,1)
        text(data(i,1), data(i,2), strrep(name(i),'_',''), ...
            'FontSize', 8, 'Color', [1 1 1] / 2);
    end
    hold off
end

