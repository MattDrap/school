function [outputData, outputName] = findSubDir(input, input_filter)

	if ~exist('input_filter')
		input_filter = '^(?!fmask).*tif';
	end

	[folder, name, ext] = fileparts(input);
	if isempty(folder)
		folder = pwd;
	end
	if isempty(ext)
		if isdir(fullfile(folder, name))
			folder = fullfile(folder, name);
			filter = input_filter;
		else
			error('Folder (%s) not found', folder);
		end
    end
    dstr = dir(folder);%search current directory and put results in structure
    outputData = {};
    outputName = {};
    for file_iterator = 1:length(dstr)
        if dstr(file_iterator).isdir && ~strcmp(dstr(file_iterator).name,'.') && ~strcmp(dstr(file_iterator).name,'..')
            pname = fullfile(folder,dstr(file_iterator).name);
            OutfilesTemp= recursdir(pname, filter);
            if ~isempty(OutfilesTemp)
                outputName{end + 1} = dstr(file_iterator).name;
                %reduce fmask?
                outputData{end + 1} = OutfilesTemp;
            end
        end
    end
end

function Outfiles=recursdir(baseDir,searchExpression)
% OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
% A recursive search to find files that match the search expression
%

dstr = dir(baseDir);%search current directory and put results in structure
Outfiles = {};
for file_iterator = 1:length(dstr)
    if ~dstr(file_iterator).isdir && ~isempty(regexp(dstr(file_iterator).name,searchExpression,'match'))
    %look for a match that isn't a directory
        Outfiles{length(Outfiles)+1} = fullfile(baseDir, dstr(file_iterator).name);
    elseif dstr(file_iterator).isdir && ~strcmp(dstr(file_iterator).name,'.') && ~strcmp(dstr(file_iterator).name,'..')
    %if it is a directory(and not current or up a level), search in that
        pname = fullfile(baseDir,dstr(file_iterator).name);
        OutfilesTemp=recursdir(pname,searchExpression);
        if ~isempty(OutfilesTemp)
        %if recursive search is fruitful, add it to the current list
            Outfiles((length(Outfiles)+1):(length(Outfiles)+length(OutfilesTemp))) = OutfilesTemp;
        end
    end
end
end