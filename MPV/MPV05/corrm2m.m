function corrs=corrm2m(qvw, vw, relevant, opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
K = size(relevant, 2);
corrs = cell(1, K);
qdict = sparse(ones(1, length(qvw)), double(qvw), 1, 1, 50000);
qind = find(qdict >= 1);

for i = 1:K
    simvw = vw{relevant(i)};
    simdict = sparse(ones(1, length(simvw)), double(simvw), 1, 1, 50000);
    simind = find(simdict >= 1);
    
    simMN = zeros(size(qind));
    
    Q = size(qind, 2);
    for j = 1:Q
        is_there = qind(j) == simind;
        if any(is_there)
            M = qdict(1, qind(j));
            N = simdict(1, simind(is_there));
            simMN(j) = M*N;
        end
    end
    [val, ind] = sort(simMN);
    for j = 1:Q
        if val(j) == 0
            continue;
        end
        indtoq = find(qind(ind(j)) == qvw);
        indtos = find(qind(ind(j)) == simvw);
        [A, B] = meshgrid(indtoq,indtos);
        cor = [A(:)';B(:)'];
        if size(cor, 2) > opt.max_MxN
            cor = cor(:, 1:opt.max_MxN);
        end
        corrs{i} = [corrs{i}, cor];
        if size(corrs{i}, 2) > opt.max_tc
            cor = corrs{i};
            corrs{i} = cor(:, 1:opt.max_tc);
            break;
        end
    end
end
end