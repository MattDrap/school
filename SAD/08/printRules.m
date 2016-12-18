function printRules(rules, info, filename)
% printRules(rules, info, filename)
%-----------------------------------------------------------
% created by Jan Hrdlicka, 16.9.2010
%-----------------------------------------------------------
% this function prints association rules to the textfile.
% Input: 
% rules: Association rules in Mx4 cell array. M is number of the found rules. In the 1st column are antecedents of the rules,
% in the 2nd column are consequents. In the 3rd column is support and in
% the 4th confidence. 
% info: Cell array with strings containing description of each item.
% filename: String with textfile path and name
fid = fopen(filename,'w+');

for i = 1:size(rules,1)
    antecedent = rules{i,1};
    consequent = rules{i,2};
    fprintf(fid,'(');
    for j = 1:length(antecedent)-1
        ind = antecedent(j);
        fprintf(fid,'%s and ',info{ind});
    end
    fprintf(fid,'%s)',info{antecedent(end)});
    fprintf(fid,'--->  (');
    for j = 1:length(consequent)-1
        ind = consequent(j);
        fprintf(fid,'%s and ',info{ind});
    end
    fprintf(fid,'%s),  ',info{consequent(end)});
    fprintf(fid,'Support = %0.2f',rules{i,3});
    fprintf(fid,', Confidence = %0.2f \n',rules{i,4});
end

fclose(fid);
