function [] = highlight()

handles = get(gcf, 'userdata'); 
H = handles.H;

%deselect all 
delete(handles.selection);

%select gco
[~,i] = find(H==gco);
x = get(H(1,i), 'XData'); x = x(1:4);
y = get(H(1,i), 'YData'); y = y(1:4);
col = get(H(1,i), 'color'); 
hs1 = fill(x,y, 'b', 'edgecolor', col, 'facecolor', col, 'facealpha', 0.25);

pos = get(H(2,i), 'position'); 
str = get(H(2,i), 'string');
hs2 = text(pos(1),pos(2),str);

set(hs2, 'backgroundcolor', 'w', 'edgecolor', col);
set(hs2, 'position', get(H(2,i), 'position')); 
set(hs2,'horizontalalignment', 'center', 'verticalalignment', 'bottom'); 
set(hs2, 'color', col); 

handles.selection(1) = hs1;
handles.selection(2) = hs2;
set(gcf, 'userdata', handles);

uistack(hs2, 'top');