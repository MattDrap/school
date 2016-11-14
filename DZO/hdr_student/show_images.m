function fig = show_images(im, info)
%SHOW_IMAGES Show images.
%
% fig = show_images(im)
%
% Input:
%  im [1xN cell] Cell array of images, same size and type.
%

[h, w] = grid_size();
fill = h*w - numel(im);
im(end+1:end+fill) = repmat({zeros(size(im{1}), class(im{1}))}, [1 fill]);
big = cell2mat(reshape(im, [w h])');
fig = figure();
imshow(big);

    function [h, w] = grid_size()
        d = ceil(sqrt(numel(im)));
        if d*(d-1) >= numel(im)
            if size(im{1},2) >= size(im{1},1)
                w = d - 1;
                h = d;
            else
                w = d;
                h = d - 1;
            end
        else
            w = d; h = d;
        end
    end

end
