function [ im, mask  ] = ReadSat( filename, par )
%ReadSat Reads Sattelite image from filename
%   realize basic NaN filtering / discards file if not allowing
%   incompleteness
%   filename -- name of the file
%   par -- structure of parameters

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
end

