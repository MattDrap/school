function visualize_2norm( cont1, cont2, q )

% Plotting the Gaussian Mixture Model
figure, pgmm(cont1,{'color','r'}), hold on;
pgmm(cont2,{'color','r'});

line([q.t1 q.t1],[0 3*1.0e-4]);
line([q.t2 q.t2],[0 3*1.0e-4]);
hold off;
