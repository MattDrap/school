function [im] = read_rgb_images(p)

d = fileparts(p);
f = dir(p)';
im = arrayfun(@(f) imread(fullfile(d, f.name)), f, 'UniformOutput', false);
im = cellfun(@(f) double(f)/255, im, 'UniformOutput', false);
