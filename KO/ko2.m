%addpath(path,'C:\Program Files (x86)\MATLAB\R2014b\toolbox\TORSCHE-master\scheduling')

%%
row = [1, zeros(1, 16), 1*ones(1,7)];
A = zeros(24 ,24);
for i = 1:24
    A(i, :) = row;
    row = circshift(row, [2 1]);
end
c = ones(24, 1);
b = [6 6 6 6 6 8 9 12 18 22 25 21 21 20 18 21 21 24 24 18 18 18 12 8]';

%%
sense=1;               %sense of optimization: 1=minimization, -1=maximization
char = 'G';
ctype = repmat(char, 24, 1);
%ctype = ['L','E']';    %constraint type: 'E'="=", 'L'="<=", 'G'=">="

lb = zeros(24, 1);           %lower bound of the variables
ub = 100 * ones(24, 1);           %upper bound of the variables
char = 'I';
vartype = repmat(char, 24, 1);
%vartype = ['I','I']';  %variable type: 'C'=continuous, 'I'=integer

%optimization parameters
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
%call command for ILP
[xmin,fmin,status,extra] = ilinprog(schoptions,sense,c,A,b,ctype,lb,ub,vartype);

%show the solution
if(status==1)
    disp('Solution: '); disp(xmin)
    disp('Objective function: '); disp(fmin)
else
    disp('No feasible solution found!');
end;

fix = A*xmin;
figure;
hold on;
b1 = bar(0:23, [fix, b(1:24)]);
b1(1).FaceColor = 'yellow';
b1(2).FaceColor = 'green';
legend('planned shifts', 'personnel demand')
xlim([-1, 25]);
hold off;


%%

row = [-1, zeros(1, 23)];
A2= zeros(48 , 48);
for i = 1:24
    A2(i, 25:end) = row;
    A2(i, 1:24) = A(i, :);
    row = circshift(row, [2 1]);
end

row = [-1, zeros(1, 23)];
for i = 1:24
    A2(i+24, 25:end) = row;
    A2(i+24, 1:24) = -1*A(i, :);
    row = circshift(row, [2 1]);
end

c = [zeros(24, 1); ones(24, 1)] ; % q1, q2, ... qn, z1, z2, ... zn
b2 = [6 6 6 6 6 8 9 12 18 22 25 21 21 20 18 21 21 24 24 18 18 18 12 8]';
B2 = [b2;-1*b2];

sense=1;               %sense of optimization: 1=minimization, -1=maximization
char = 'L';
ctype = repmat(char, 48, 1);

lb = zeros(48, 1);           %lower bound of the variables
ub = 100 * ones(48, 1);           %upper bound of the variables
char = 'I';
vartype = repmat(char, 48, 1);

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
%call command for ILP
[xmin2,fmin,status,extra] = ilinprog(schoptions,sense,c,A2,B2,ctype,lb,ub,vartype);

xmin2_x = xmin2(1:24);
xmin2_z = xmin2(25:end);
%show the solution
if(status==1)
    disp('Solution: '); disp(xmin2_x)
    disp('Objective function: '); disp(fmin)
else
    disp('No feasible solution found!');
end;

fixation2 = zeros(24, 1);
for i = 1:24
    for j = 1:8
        look_back = mod(i-j, 24) + 1;
        fixation2(i) =fixation2(i) + xmin2_x(look_back);
    end
end

figure;
hold on;
b2 = bar(0:23, [fixation2, b(1:24)]);
b2(1).FaceColor = 'yellow';
b2(2).FaceColor = 'green';
legend('planned shifts', 'personnel demand')
xlim([-1, 25]);
hold off;