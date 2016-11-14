%  proces = [4, 5, 1, 2;
%                  2, 1, 3, 4];
%              [perm, res] = PFS(proces)
%              
% proces = [2,1 ,5; 1,3,4;7,1,1];
% [perm, res] = PFS(proces)
% proces = [2, 4; 3, 1; 4, 2];
% [perm, res] = PFS(proces)
% proces = [5, 5, 3, 6, 3;
%            4, 4, 2, 4, 4;
%            4, 4, 3, 4, 1;
%            3, 6, 3, 2, 5]; %transpose
% [perm, res] = PFS(proces')

max_j = 20;
min_j = 3;
num_rep = 5;

BBTimes = zeros(17, 17, num_rep);
EnumTimes = zeros(17, 17,  num_rep);
counter = 1;
for job = min_j:max_j
    'job'
    job
    for machine = 3:20
        for i = 1:num_rep
            tab = rand(job, machine);
            stime = tic;
            [perm, res] = PFS(tab);
            endtime = toc(stime);
            BBTimes(job - 2, machine - 2, i) = endtime;
        
%         stime = tic;
%         [perm, res] = PFSEnumerate(tab);
%         endtime = toc(stime);
%         EnumTimes(job - min_j + 1, i) = endtime;
        end
    end
end
%%
figure;
hold on;
title('Porovnání ryhchlosti zpracování');
xlabel('Poèet prací');
ylabel('Èas zpracování v s');
plot(min_j:max_j, mean(BBTimes, 2));
plot(min_j:max_j, mean(EnumTimes, 2));
legend('Branch Bound', 'Enumerativní øešení');
hold off;