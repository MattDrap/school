% Data
par.data_dir = 'F:\CVUT\SVP - Dipl\Data\sensorsProcessed\';%'F:\CVUT\SVP - Dipl\Data\urban_dynamic_v3.0\data';   %path to data folder
%'/Users/zimmerk/projects/GISAT_ESA_ITI/data/iti_urban_dynamic_landsat_praha/' 

% Ground truth
par.gt = './GT/PRG_ref_stable_change_default.tif';
par.global_normalization = false;
par.global_normalization_trim = 0.01;
par.allow_incomplete_feature_vectors = false;

%Cloud Approximation
par.max_metaClouds = 3500;
par.init_radius = 50;
par.min_radius = 5;

par.k2 = 0.01;
par.k1 = 0.01;
par.max_iter_opt = 100;
par.metadata_path = 'F:\CVUT\SVP - Dipl\iti_urban_dynamic_landsat_praha_metadata.csv';
par.parallel = false;
par.subb = 5;
par.threshold = 10;

par.sun_elevation = 30;
par.sun_azimuth = 150;
par.cloud_height_min = 20;
par.cloud_height_max = 30;

[par.file_list, par.file_dirs] = findSubDir(par.data_dir);