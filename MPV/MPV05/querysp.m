function [scores, img_ids, A]=querysp(qvw, qgeom, bbx, vw, geom, DB, idf, opt)
%UNTITLED3 Summary of this function goes here
%   bbx [xmin, ymin, xmax, ymax];

log1 = bbx(3) >= qgeom(1,:);
log2 = qgeom(1, :) >= bbx(1);
log3 = bbx(4) >= qgeom(2,:);
log4 = qgeom(2, :) >= bbx(2);

log = log1 & log2 & log3 & log4;

qvw = qvw(:, log);
qgeom = qgeom(:, log);

[aimg_ids, ascore]=query(DB, qvw, idf);
img_ids = aimg_ids(1:opt.max_spatial);
score = ascore(1:opt.max_spatial);
corrs = corrm2m(qvw, vw, img_ids, opt);
[scores, A] = ransacm2m(qgeom, geom, corrs, img_ids, opt);
scores = scores + score;
scores(isnan(scores)) = 0;
[scores, inds] = sort(scores, 'descend');

%% expansion

if isfield(opt, 'max_qe')
    max = 10;
    expscore = [];
    if size(qvw, 2) < opt.max_qe
        expscore = scores(scores > max);
        expinds = inds(scores > max);
        expA = A(:,:,scores > max);
        for i =1:size(expinds, 2)
            A1 = inv(expA(:,:, i));
            expgeom = geom{i};
            expvw = vw{i};
            projected = A1 * [expgeom(1:2, :); ones(1, size(expgeom, 2))];


            log1 = bbx(3) >= projected(1,:);
            log2 = projected(1, :) >= bbx(1);
            log3 = bbx(4) >= projected(2,:);
            log4 = projected(2, :) >= bbx(2);

            log = log1 & log2 & log3 & log4;

            subprojected = projected(:, log);
            subexpvw = expvw(log);
            subexpgeom = expgeom(:, log);
            for j = 1:size(subexpvw, 2)
                if find(subexpvw(j) ~= qvw)
                    if size(qvw, 2) + 1 > opt.max_qe
                        break;
                    end
                    qvw = [qvw, subexpvw(j)];
                    qgeom = [qgeom, [subprojected(1:2, i); subexpgeom(3, j); subexpgeom(4, j); subexpgeom(5, j); subexpgeom(6, j)]];
                end
            end
        end
    end
                        
    if ~isempty(expscore)
        [scores, img_ids, A] = querysp(qvw, qgeom, bbx, vw, geom, DB, idf, opt);
    else
        img_ids = img_ids(inds);
        A = A(:,:, inds);
    
    end
end
    %%
  img_ids = img_ids(inds);
  A = A(:,:, inds);
end

