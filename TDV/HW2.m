im = imread('tdv201603.png');
figure;
imshow(im);
hold on;
%four corners of skyscraper
p = ginput(4);
p = p';
addpath('./Misc');
%lines from skyscraper
l1 = cross(e2p(p(:, 1)), e2p(p(:, 2)));
l2 = cross(e2p(p(:, 2)), e2p(p(:, 3)));
l3 = cross(e2p(p(:, 3)), e2p(p(:, 4)));
l4 = cross(e2p(p(:, 4)), e2p(p(:, 1)));

%vanishing points
vp1 = cross(l1, l3);
vp2 = cross(l2, l4);

%horizont / vanishing line
vl = cross(vp1, vp2);

%%
%Plotting
figure;
imshow(im);
hold on;
[H, W, C] =size(im);
Borders = [1, W;
           1, H];
[cp1, cp2] = getLineLine(l1, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'b');
[cp1, cp2] = getLineLine(l2, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'g');
[cp1, cp2] = getLineLine(l3, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'b');
[cp1, cp2] = getLineLine(l4, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'g');

[cp1, cp2] = getLineLine(vl, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'r');

%%
%foot of the building
fpoints = ginput(2);
fpoints = fpoints';
fline = cross(e2p(fpoints(:, 1)), e2p(fpoints(:, 2)));

%cross of fline and horizont
point_m = cross(fline, vl);

%tall building B point
tp = ginput(1);
tp = tp';
BAline = cross(e2p(tp), point_m);
%%
%2nd plotting
[cp1, cp2] = getLineLine(fline, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'k');

[cp1, cp2] = getLineLine(BAline, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'y');
%%
%get top of building A
tap = ginput(1);
tap = tap';
scraper_lineA = cross(e2p(tap), e2p(fpoints(:, 2)));
scraper_lineB = cross(e2p(tp), e2p(fpoints(:, 1)));
Zpoint = cross(scraper_lineA, scraper_lineB);

looking_line = cross(Zpoint, e2p(tap));


Q1 = p2e(cross(fline, looking_line)); %P0
Q2 = p2e(cross(looking_line, BAline)); %P1
Q3 = tap;   %P
Q4 = p2e(Zpoint); %PInf
%%
%ANS
[cp1, cp2] = getLineLine(looking_line, Borders);
plot([cp1(1), cp2(1)], [cp1(2), cp2(2)], 'r');
plot(Q1(1), Q1(2), 'ko');
plot(Q2(1), Q2(2), 'ko');
plot(Q3(1), Q3(2), 'ko');
plot(Q4(1), Q4(2), 'ko');
(det([Q1, Q3]) * det([Q4,Q2])) / (det([Q2, Q1]) * det([Q3, Q4]) )