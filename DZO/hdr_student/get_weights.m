function w = get_weights(L, Z, type)
%GET_WEIGHTS Get intensity weights.
%
% Input:
%   L [1x1 double] Number of intensity levels.
%   Z [any double] Intensities from [0, L-1].
%   type [char] Either 'hat' (default) or 'ramp'.
%
% Output:
%   w [size(Z) double] Intensity weights.
%

if nargin < 3
    type = 'hat';
end

switch type
    case 'hat'
        w = interp1([0 (L-1)/2 L-1], [0 1 0], Z);
    case 'ramp'
        w = interp1([0 (L-2)   L-1], [0 1 0], Z);
end

end
