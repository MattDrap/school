% load('mpvcx50k_haff2.mat');
% load('mpvdb50k_haff2.mat');
% load('mpvdesc_haff2.mat');
%%
classInd = 1 -1;
query_id = [];
%%
for i = (2*classInd+1):(2*classInd+5)
    ff = strfind(NAMES, sprintf('pokemons_view0%d', i));
    index = find(not(cellfun('isempty', ff)));
    query_id = [query_id, index];
end
%%
UKbench = {'ukbench00088', 'ukbench00108', 'ukbench00148', 'ukbench00165', 'ukbench00231'};
OXbench = {'ox5k_bodleian_000106','ox5k_bodleian_000283','ox5k_bodleian_000324','ox5k_bodleian_000340', ...
           'ox5k_bodleian_000364','ox5k_bodleian_000379','ox5k_bodleian_000396','ox5k_all_souls_000041', ...
           'ox5k_all_souls_000075','ox5k_ashmolean_000223'};
for i = 1:size(UKbench, 2)
    ff = strfind(NAMES, UKbench{i});
    index = find(not(cellfun('isempty', ff)));
    query_id = [query_id, index];
end
for i = 1:size(OXbench, 2)
    ff = strfind(NAMES, OXbench{i});
    index = find(not(cellfun('isempty', ff)));
    query_id = [query_id, index];
end
%%
%idf = getidf(VW, 50000);
%DB = createdb_tfidf(VW, 50000, idf);

mVW = cell(20, 1);
for i = 1:size(query_id, 2)
    %[idxs, dists]=nearest(CX, DESC{query_id(i)});
    mVW{i} = VW{query_id(i)};%mVW{i} = idxs;
 end


%%
query_bbx = zeros(4, 20);
for i = 1:size(query_id, 2)
   f = figure;
   imshow(sprintf('Images/%s.jpg', NAMES{query_id(i)}));
   h = imrect(gca);
   pos = h.getPosition();
   query_bbx(:, i) = [pos(1); pos(2); pos(1) + pos(3); pos(2) + pos(4)];
   close(f);
end

%%
qGEOM = cell(20, 1);
qVW = cell(20, 1);
 for i = 1:size(query_id, 2)
      mGEOM = GEOM{query_id(i)};
      
      log1 = query_bbx(3, i) >= mGEOM(1,:);
      log2 = mGEOM(1, :) >= query_bbx(1, i);
      log3 = query_bbx(4, i) >= mGEOM(2,:);
      log4 = mGEOM(2, :) >= query_bbx(2, i);

      log = log1 & log2 & log3 & log4;
      geom = mGEOM(:, log);
      qGEOM{i} = geom;
      vw = mVW{i};
      qVW{i} = vw(log);
 end
 
%%
opt.max_tc=600;
opt.max_MxN=10;
opt.max_spatial=50;
% directory where you unzipped mpvimgs.zip
opt.root_dir='../MPV05Data/Images';
% opt.subplot=1;
opt.threshold=8;

query_results = cell(20, 1);

 for i = 1:size(query_id, 2)
     qvw = qVW{i};
     qgeom = qGEOM{i};
     bbx = query_bbx(:, i);
    [scores, img_ids, A]=querysp(qvw, qgeom, bbx, VW, GEOM, DB, idf, opt);
    Q.score = scores;
    Q.img_ids = img_ids;
    Q.A = A;
    query_results{i} = Q;
    %showresults(img_ids(1:5), scores, A, bbx', opt, NAMES);
 end
 
 save('results.mat', 'query_results', 'query_id', 'query_bbx', 'opt');