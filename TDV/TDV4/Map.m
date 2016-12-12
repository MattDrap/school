figure;
hold on;
place_of_i = plot3(0,0,1.7, 'bx');
height = [0.5, 1.5, 2.0];

cams = [12, 9, 6, 3,10, 7, 4, 1,11, 8, 5, 2];

id_cam = 1;
for i = 1:3
    for j = 1:4
        place = plot3(mp(j, 2), mp(j, 1), height(i), 'ro');
        text(mp(j, 2), mp(j, 1), height(i), sprintf('%d', cams(id_cam)));
        id_cam = id_cam + 1;
    end
end

for i = 1:3
    for j = 1:3
        lines = plot3([ mp(j, 2) mp(j+ 1, 2)], [mp(j, 1) mp(j + 1, 1)], [height(i), height(i)], 'r');
        text( mean([ mp(j, 2) mp(j+ 1, 2)]),...
            mean([mp(j, 1) mp(j + 1, 1)]), ...
            mean([height(i), height(i)]), '1.5 m');
    end
end

for j = 1:4
    for i = 1:2
        lines2 = plot3([ mp(j, 2) mp(j, 2)], [mp(j, 1) mp(j, 1)], [height(i), height(i + 1)], 'g');
        if(i == 1)
            tt = '1m';
        else
            tt = '0.5m';
        end
        text( mean([ mp(j, 2) mp(j, 2)]),...
            mean([mp(j, 1) mp(j, 1)]), ...
            mean([height(i), height(i + 1)]), tt);

    end
end
legend([place_of_i, place, lines, lines2], 'Modelovaný objekt', 'Místo odkud se fotografovalo', ...
      'Horizontální Posun', 'Vertikální posun');
zlim([0, 2]);