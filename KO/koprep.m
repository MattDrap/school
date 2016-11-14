addpath(path,'C:\Program Files (x86)\MATLAB\R2014b\toolbox\TORSCHE-master\scheduling')
n = 12;
m = 4;
k = 5;
A = [
    1   0   0   1;
    0   1   0   1;
    0   0   1   1;
    0   0   1   1;
    1   1   0   1;
    0   1   0   0;
    1   1   1   1;
    0   0   0   1;
    0   0   1   1;
    1   0   1   0;
    0   1   0   1;
    0   1   1   1];
D = [
    0   1   1   1;
    0   0   1   1;
    1   0   0   1;
    0   1   1   1;
    1   1   0   1];
bk = sum(D, 2);

b = [zeros(n+m+k, 1); 12; -12];
l = zeros(n+m+k + 2);
C = zeros(n+m+k + 2);
u = [zeros(n),  zeros(size(A)),     zeros(n, k) ,   zeros(n , 1),   ones(n, 1);
        A',             zeros(m, m),       zeros(m,k),   zeros(m, 2);
        zeros(k, n), D,                      zeros(k, k),    zeros(k ,2);
     zeros(1, n),  zeros(1, m),       bk',       0, 0;
     zeros(1, n+m+k+2)];
G = graph();
F = G.mincostflow(C,l,u,b);

F(n+1:n+m, 1:n)
F(n+m+1:n+m+k, n+1:n+m)
