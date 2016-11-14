load('HW2.mat');
Dalib = load('daliborka_01-ux.mat');
%%
[K, R, C] = Q2KRC(Q);
pix_wid = 5*1e-6;
f = K(1,1)*pix_wid;

width = 1100;
height = 850;

Delta = eye(3);
Kappa = f*Delta;
Epsilon =  Delta * inv(R);
Nu = Epsilon * inv(K);
Gamma = f * Epsilon;
Beta = f*Nu;
Alpha = Beta * [1, 0;
                0, 1;
                0, 0];

a = C + Beta(:, 3);
d = [0, 0, 0]';
e = C;
n = C;
b = C;
g = C;
k = [0,0,0]';

Pb = [1/f*K*R, -1/f*K*R*C];

save( '03_bases.mat', 'Pb', 'f', 'Alpha', 'a', 'Beta', 'b', 'Gamma', 'g', ...
      'Delta', 'd', 'Epsilon', 'e', 'Kappa', 'k', 'Nu', 'n', '-v6' );
%%
Beta(:, 1) = Beta(:, 1) .* width;
Beta(:, 2) = Beta(:, 2) .* height;

Alpha(:, 1) = Alpha(:, 1) .* width;
Alpha(:, 2) = Alpha(:, 2) .* height;
figure_1 = figure;
hold on;
plot_csystem(Delta, d, 'k', '\delta');
plot_csystem(Epsilon, e, 'm', '\epsilon');
plot_csystem(Kappa, k, [200, 100, 50]/255, '\kappa');
plot_csystem(Nu, n, 'c', '\nu');
plot_csystem(Beta * 50, b, 'r', '\beta');
scatter3(x(1, :), x(2, :), x(3, :), 30, 'b'); %show points
hold off;
axis equal;
fig2pdf(figure_1, '03_figure1.pdf' );
%%
figure_2 = figure;
hold on;
plot_csystem(Alpha, a, 'g', '\alpha');
plot_csystem(Gamma, g, 'b', '\gamma');
plot_csystem(Beta, b, 'r', '\beta');
scatter(Dalib.u(1, :), Dalib.u(2, :), 5, 'b'); %show points;
hold off;
axis equal;
fig2pdf(figure_2, '03_figure2.pdf' );
%%  
figure_3 = figure;
hold on;
plot_csystem(Delta, d, 'k', '\delta');
plot_csystem(Epsilon, e, 'm', '\epsilon');
scatter3(x(1, :), x(2, :), x(3, :), 5, 'b'); %show points;
for i = 1:length(Q_all)
   [~, ~, C_pos] = Q2KRC(Q_all{i});
   scatter3(C_pos(1), C_pos(2), C_pos(3), 5 , 'r');
end
hold off;
axis equal;
%fig2pdf(figure_3, '03_figure3.pdf' );