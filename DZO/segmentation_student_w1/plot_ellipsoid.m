function plot_ellipsoid(mean, cov, color, scale)
% Plot 3D ellipsoid determined by its mean vector and covariance matrix
% with the specified color. The ellipsoid can be optionally scaled.

NUM_THETA = 16;
NUM_PHI = 16;
NUM_PTS = NUM_THETA * NUM_PHI;

if ~exist('scale', 'var')
	scale = 1;
end

% compute transformation matrix
[U, D] = eig(cov);
A = U * sqrtm(D) * scale;

% generate points uniformly distributed on the sphere
x = zeros(3, NUM_PTS);
sample = 1;
for t = 1:NUM_THETA;
	for p = 1:NUM_PHI;
		theta = 2 * pi * (t / NUM_THETA);
		phi = pi * ((p / NUM_PHI) - 0.5);

		x(1,sample) = cos(phi) * cos(theta);
		x(2,sample) = cos(phi) * sin(theta);
		x(3,sample) = sin(phi);

		sample = sample + 1;
	end
end

% transform the sphere to the ellipsoid
y = A * x + repmat(mean, [1 NUM_PTS]);

% plot the ellipsoid
for sample = 1:NUM_PTS
    y0(:,1) = y(:,sample);
    y1(:,1) = y(:,mod(sample,NUM_PTS)+1);
    y2(:,1) = y(:,mod(sample+NUM_PHI-1,NUM_PTS)+1);
    
    l1 = [y0'; y1'];
    l2 = [y0'; y2'];
    
    if (mod(sample, NUM_PHI) ~= 0)
        line(l1(:,1), l1(:,2), l1(:,3), 'Color', color);
    end
    line(l2(:,1), l2(:,2), l2(:,3), 'Color', color);
end

end
