function [ im, mask ] = Sat2Im( filename, par )
    im = double( imread( filename ) );
    [pth, file, ext] = fileparts(filename);
    mask = imread([pth,filesep,'fmask',file(7:end), ext]);
    %imshow(im(:, :, [4, 5, 3]));
    for k=1:size(im,3),
        aux = im(:,:,k);
        aux(mask > 2) = NaN;
        aux(aux > 1e4) = NaN;
        aux(aux < 0) = NaN;
        im(:,:,k) = aux;
    end
    clear aux;
    if ~par.allow_incomplete_feature_vectors
        im(repmat(any(isnan(im),3),[1,1,6])) = nan;
    end;
    im = im(:, :, [3, 2, 1]) ./ 1e+4;

    % GLOBAL normalization
    if par.global_normalization
        trim = par.global_normalization_trim;
        for c=1:size(im, 3),
            aux = im(:,:,c);
            [a b]= hist(aux(:), 0:0.001:1);
            a= cumsum(a)/sum(a);
            [u L(c)] = min(abs(a-trim));
            [u R(c)] = min(abs(a-(1-trim)));
            aux(aux<b(L(c))) = b(L(c));
            aux(aux>b(R(c))) = b(R(c));
            aux = aux - b(L(c));
            aux = aux/abs(b(R(c))-b(L(c)));
            im(:,:,c) = aux;
        end;
    end;
    im = uint8(im .* 255);
end

