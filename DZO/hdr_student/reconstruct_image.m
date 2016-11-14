function im = reconstruct_image(hdr, t, finv)
%RENDER_IMAGE Reconstruct image from HDR
%
% Input:
%   hdr  [MxNxC double] HDR image.
%   t    [1x1 double]   Exposure time.
%   finv [1xL double]   Inverse response function.
%
% Output:
%   im [MxNxC double] Rendered image.
%

finv = finv(:)';
L = numel(finv);
finv = monotonic(finv, sqrt(eps));
im = round(interp1(finv, 0:L-1, hdr .* t, 'linear', 'extrap'));
im = im ./ (L-1);
im(im < 0) = 0;
im(im > 1) = 1;

    function out = monotonic(in, min)
        s = diff(in);
        lower = s < min;
        while any(lower)
            s(~lower) = s(~lower) - sum(s(lower) - min) / sum(~lower);
            s(lower) = min;
            lower = s < min;
        end
        out = [in(1) in(1)+cumsum(s)];
    end

end
