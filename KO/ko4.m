addpath(path,'C:\Program Files (x86)\MATLAB\R2014b\toolbox\TORSCHE-master\scheduling')
%%

load('projection_data_ko.mat');
numIterations = 30;
MatSize = [20,20];
Ps = {sumR , sumC, sumD, sumA };
I = zeros(MatSize);
NI = zeros(MatSize);
lenC = length(sumC);
lenR = length(sumR);
lenD = length(sumD);
lenA = length(sumA);

G = graph();

for i =1:numIterations
    
    figure;
    
    %sumR sumC
    C = zeros(lenR + lenC, lenR + lenC);
    for j = 1:lenR
        for k=1:lenC
            C(j ,lenC + k) = 1 - I(j,k);
        end
    end
    l = zeros(size(C));
    u = zeros(size(C));
    u(1:lenR, lenC:2*lenC) = 1;
    b = [sumR, -sumC]';
    F = G.mincostflow(C,l,u,b);
    NI = F(1:lenR, lenC+1:2*lenC);
    
    if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
    
    subplot(3,3,1);
    title(sprintf('Iteration %d', i));
    hold on;
    subimage(logical(I));
    colormap(gray);
    
    %sumR sumD 
    C = zeros(lenD + lenR, lenD + lenR);
    u = zeros(size(C));
    for j = 1:lenR
        for k=1:lenC
            C(j , lenR + ceil(lenD/2) +k - j) = 1 - I(j,k);
            u(j , lenR + ceil(lenD/2) +k - j) = 1;
        end
    end
    l = zeros(size(C));
    b = [sumR,  -sumD]';
    F = G.mincostflow(C,l,u,b);
    
    for j = 1:lenR
        for k=1:lenR
            NI(j,k) = F(j , lenR + ceil(lenD/2) +k - j);
        end
    end
    
    if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
    
    subplot(3,3,2);
    hold on;
    subimage(logical(I));
    colormap(gray);
    
    %sumR sumA
    C = zeros(lenR + lenA, lenR + lenA);
    u = zeros(size(C));
    for j = 1:lenR
        for k=1:lenC
            C(j , lenR + k + j - 1) = 1 - I(j,k);
            u(j , lenR + k + j - 1) = 1;
        end
    end
   
    l = zeros(size(C));
    b = [sumR, -sumA]';
   
    F = G.mincostflow(C,l,u,b);
    
    for j = 1:lenR
        for k=1:lenC
            NI(j,k) = F(j , lenR + k + j - 1);
        end
    end
    
    if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
    
    subplot(3,3,3);
    hold on;
    subimage(logical(I));
    colormap(gray);
    
    %sumC sumD 
    C = zeros(lenC +lenD, lenC + lenD);
    u = zeros(size(C));
    for j = 1:lenR
        for k=1:lenC
            C(k, lenC + ceil(lenD/2) + k - j) = 1 - I(j,k);
            u(k, lenC + ceil(lenD/2) + k - j) = 1;
        end
    end
   
    l = zeros(size(C));
    b = [sumC, -sumD]';
   
    F = G.mincostflow(C,l,u,b);
    
   for j = 1:lenR
        for k=1:lenC
            NI(j,k) = F(k, lenC + ceil(lenD/2) + k - j);
        end
   end
   
   if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
   
   subplot(3,3,4);
    hold on;
    subimage(logical(I));
    colormap(gray);
   
   %sumC sumA
    C = zeros(lenC + lenA, lenC + lenA);
    u = zeros(size(C));
    for j = 1:lenR
        for k=1:lenC
            C(k, lenC + k + j - 1) = 1 - I(j,k);
            u(k, lenC + k + j - 1) = 1;
        end
    end
   
    l = zeros(size(C));
    b = [sumC, -sumA]';
   
    F = G.mincostflow(C,l,u,b);
    
   for j = 1:lenR
        for k=1:lenC
            NI(j,k) = F(k, lenC + k + j - 1);
        end
   end 
   
   if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
   
   subplot(3,3,5);
    hold on;
    subimage(logical(I));
    colormap(gray);
    
     %sumD sumA
    C = zeros(lenD +lenA, lenD + lenA);
    u = zeros(size(C));
    for j = 1:lenR
        for k=1:lenC
            C(ceil(lenD/2) + k - j, lenD +  k + j - 1) = 1 - I(j,k);
            u(ceil(lenD/2) + k - j, lenD +  k + j - 1) = 1;
        end
    end
   
    l = zeros(size(C));
    b = [sumD, -sumA]';
   
    F = G.mincostflow(C,l,u,b);
    
   for j = 1:lenR
        for k=1:lenC
            NI(j,k) = F(ceil(lenD/2) + k - j, lenD +  k + j - 1);
        end
   end
   
   if sum(I(:) ~= NI(:)) == 0
        break
    end
    I = NI;
   
   subplot(3,3,6);
    hold on;
    subimage(logical(I));
    colormap(gray);
    
end

figure;
imagesc(logical(NI));
colormap(gray);
axis off;
axis square;