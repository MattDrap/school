function [H] = show_detections(bboxes, scores, class_ids, class_names)
%SHOW_DETECTIONS - display detection results
%
%  [H] = show_detections(bboxes, scores, class_ids, class_names)
%
%    bboxes - (Nx4) bounding boxes
%    scores - (Nx1) scores of detections
%    class_ids - (Nx1) class identifiers (pointer into class_names)
%    class_names - (Kx1) cell array of textual class descriptions 
%
%    H - handle to drawn objects
%   
%  Note: A detection can be highleghted on click 
%

min_score = (min(scores));
max_score = (max(scores));
H = [];

num_of_classes = length(unique(class_ids));
col = jet(num_of_classes);
col_idx = NaN(1000,1);
col_idx(unique(class_ids)) = 1:num_of_classes;
for i = 1:length(scores)
    bb = bboxes(:,i);
    score = scores(i);
    class_id = class_ids(i);
    class = class_names{class_id}; 
    
    k=(5-0.5)/(max_score-min_score);
    q = 5-k*max_score;
    lw = k*score+q;
    
    H(1,i) = plotbox(bb); %, 'facealpha', 0); 
    %set(H(1,i), 'edgecolor', col(col_idx(class_id),:)); 
    %set(H(1,i), 'facecolor', col(col_idx(class_id),:)); 
	set(H(1,i), 'color', col(col_idx(class_id),:)); 
    set(H(1,i), 'linewidth', lw); 
    
    H(2,i) = text(0.5*(bb(1)+bb(3)), bb(2), sprintf('%.3f %s', score, class));
    set(H(2,i), 'color', col(col_idx(class_id),:)); 
    set(H(2,i),'horizontalalignment', 'center', 'verticalalignment', 'bottom'); 
end
handles.H = H;
handles.selection = [];
set(gcf, 'userdata', handles);
set(H, 'ButtonDownFcn', 'highlight()');


