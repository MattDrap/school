function plot_ellipse(mean, cov, color, scale)
% Plot 2D ellipse determined by its mean vector and covariance matrix
% with the specified color. The ellipse can be optionally scaled.

NUM_PTS = 64;

if ~exist('scale', 'var')
	scale = 1;
end

% compute transformation matrix
[U, D] = eig(cov);
A = U * sqrtm(D) * scale;

% generate points uniformly distributed on the circle
phi = linspace(0, 2 * pi, NUM_PTS + 1);
x = [cos(phi); sin(phi)];

% transform the circle to the ellipse
y = A * x + repmat(mean, [1, NUM_PTS + 1]);

% plot the ellipse
plot(y(1,:), y(2,:), 'Color', color);

end
