function [scores, A]=ransacm2m(qgeom, geom, corrs, relevant, opt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
K = size(relevant, 2);
scores = zeros(1, K);
A = zeros([3,3,K]);
allpoints = qgeom(1:2, :);
allpoints = [allpoints; ones(1, size(allpoints, 2))];

for i = 1:K
    simgeom = geom{relevant(i)};
    BestA = zeros(3,3);
    BestInl = 0;
    corr = corrs{i};
    
    for j = 1:size(corrs{i}, 2)
        indq = corr(1, j);
        inds = corr(2, j);
        C = [qgeom(3,indq), qgeom(4, indq), qgeom(1,indq);
             qgeom(5,indq), qgeom(6, indq), qgeom(2,indq);
             0, 0, 1];
        D = [simgeom(3,inds), simgeom(4, inds), simgeom(1, inds);
             simgeom(5,inds), simgeom(6, inds), simgeom(2, inds);
             0, 0, 1];
        mA = D*inv(C);
        proj = mA * allpoints;
        
        temp = proj(:, corr(1, :));
        temp2 = simgeom(1:2, corr(2, :));
        
        dists = sqrt(sum((temp2-temp(1:2, :)).^2));
        inl = dists < opt.threshold;
        
        if sum(inl) > BestInl
            BestInl = sum(inl);
            BestA = mA;
        end
      
    end
    scores(i) = BestInl;
    A(:, :, i) = BestA;
end
end

