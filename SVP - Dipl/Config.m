% Data
par.data_dir = 'C:\Users\Matt\Desktop\Gisat\urban_dynamic_v3.0\data';   %path to data folder
%'/Users/zimmerk/projects/GISAT_ESA_ITI/data/iti_urban_dynamic_landsat_praha/' 

% Ground truth
par.gt = {fullfile(par.data_dir,'/changes/PRG_2006_2009/PRG_ref_stable_change_default.tif')};
par.global_normalization = false;
par.global_normalization_trim = 0.01;
par.allow_incomplete_feature_vectors = false;

%Cloud Approximation
par.max_metaClouds = 3000;
par.init_radius = 15;

par.k2 = 0.01;
par.k1 = 0.01;
par.max_iter_opt = 100;
par.metadata_path = 'C:\Users\Matt\Downloads\CVUT\SVP - Dipl\iti_urban_dynamic_landsat_praha_metadata.csv';
par.parallel = false;
par.subb = 5;
par.threshold = 500;
