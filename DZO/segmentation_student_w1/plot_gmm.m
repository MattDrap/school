function plot_gmm(means, covs, color, scale)
% Plot GMM specified by its mean vectors and covariance matrices. Models in
% 2D vector space are plot as ellipses, 3D models as ellipsoids, other
% dimensions are unsupported. Color and scale can be specified optionally.

% by default plot with black color
if ~exist('color', 'var')
	color = [0 0 0];
end

% scale of the ellipse or ellipsoid
if ~exist('scale', 'var')
	scale = 1;
end

[d, k] = size(means);

switch d
	case 2
		for i = 1:k
			plot(means(1,i), means(2,i), ...
				'Marker', '+', 'Color', color);
			plot_ellipse(means(:,i), covs(:,:,i), color, scale);
		end
	case 3
		for i = 1:k
			plot3(means(1,i), means(2,i), means(3,i), ...
				'Marker', '+', 'Color', color);
			plot_ellipsoid(means(:,i), covs(:,:,i), color, scale);
		end
	otherwise
		error('Plotting GMM of dimension %i not supported', d);
end

end
