function [im, info] = read_images(p)
%READ_IMAGES Read sequence of images
%
% [im, info] = read_images(p)
%
% Input:
%   p [char] File path template with wildchars
%
% Output:
%   im   [1xN cell]   Cell array with read images, e.g. im{3} is the third image.
%   info [1xN struct] Struct array with meta data, e.g. from EXIF.
%
% Example:
%   im = read_images(fullfile('images', 'lamp*'));
%

d = fileparts(p);
f = dir(p)';
im = arrayfun(@(f) imread(fullfile(d, f.name)), f, 'UniformOutput', false);
info = arrayfun(@(f) imfinfo(fullfile(d, f.name)), f);

end
