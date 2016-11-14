function showPoints(xNew,p)
    p=[]; p.color = 'y'; p.marker = '.'; p.markersize = 15;
    line(xNew.x+1, xNew.y+1, 'linestyle','none', p);
    text(xNew.x+3, xNew.y-3, {num2str(xNew.ID)}','color','y');
end