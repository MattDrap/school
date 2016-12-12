function [ sun_elevation, sun_azimuth ] = FindMetadataByFilename( name, par, sceneID, acquisitionDate, sunElevation, sunAzimuth )
%FindMetadataByFilename Finds metadata based on filename given
%   Returns sun elevation and sun azimuth
%   name -- Name of the file that you want to search metadata for
%   par -- structure of parameters
if nargin < 2
    fprintf('Forgotten filename or par structure');
end
if nargin < 3
    [sceneID,acquisitionDate,sunElevation,sunAzimuth] = ...
    importfile(par.metadata_path);
end

[folder, name, ext] = fileparts(name);
dot_ind = strfind(name, '.');
dot_unds = strfind(name, '_');

name_orig = name(dot_ind + 1 : dot_unds(1) - 1);

idx = find(strcmp(sceneID, name_orig));

if isempty(idx)
    sun_elevation = 0;
    sun_azimuth = 0;
else
    sun_elevation = sunElevation(idx(1));
    sun_azimuth = sunAzimuth(idx(1));
end
end

