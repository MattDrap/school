clear all;

data.xRect = [ 290 290 230 230]; data.yRect = [ 170 200 200 170];

%% vyvoj poctu bodu

if  (exist('homography.mat','file'))
    load ('homography.mat'); 
    if (isnumeric(xHistory.ID))
	IDs = unique(xHistory.ID); nums = zeros(size(xHistory.ID));
       for a = IDs';  nums(a) = sum(xHistory.ID == a); end;
       nums = nums(nums~=0); counts = zeros(max(nums),1);
       for a = 1:max(nums);  counts(a) = sum(nums>=a); end;
       figure; plot(counts,'LineWidth',2); xlabel('Frame number'); ylabel('Number of tracking points'); ylim([0, round(length(IDs)*50)/50 ]); grid on;
       img = im2double(rgb2gray(imread('billa_jpg_283.jpeg')));
       figure; imagesc(img); colormap gray; axis image; hold on;
       plot(xHistory.x(end-counts(end)+1:end),xHistory.y(end-counts(end)+1:end),'Color',hsv2rgb(0,0.9,1),'Marker','x','LineStyle','none');
       title('Remaining points in the last frame');
    else
	fprintf('Bad xHistory format\n\n');
    end
else
    fprintf('Result file homography.mat not found\n\n');
end

%% homografie dle odevzdaneho .mat souboru
if  (exist('homography.mat','file'))
    load ('homography_ref.mat'); hHistoryRef = hHistory; xHistoryRef = xHistory; load ('homography.mat'); 
    H = eye(3);
    for a = 1:length(hHistory); H = (hHistory{a}./hHistory{a}(3,3)) * H; end
    Href = eye(3);
    for a = 1:length(hHistoryRef); Href = (hHistoryRef{a}./hHistoryRef{a}(3,3)) * Href; end
    fprintf('Your homography result:\n'); disp(H/H(3,3));
    fprintf('Our homography result:\n');  disp(Href/Href(3,3));
    tmp = H * [data.xRect; data.yRect; ones(size(data.xRect))];
    dataOut.xRect = tmp(1,:)./tmp(3,:); dataOut.yRect = tmp(2,:)./tmp(3,:);
    fprintf('Your transformed rectangle:\n'); disp([dataOut.xRect; dataOut.yRect]);
    tmp = Href * [data.xRect; data.yRect; ones(size(data.xRect))];
    dataRef.xRect = tmp(1,:)./tmp(3,:); dataRef.yRect = tmp(2,:)./tmp(3,:);
    fprintf('Our transformed rectangle:\n'); disp([dataRef.xRect; dataRef.yRect]);
    fprintf('Transforming difference:\n'); disp([dataRef.xRect - dataOut.xRect; dataRef.yRect - dataOut.yRect]);
else
    fprintf('Result file homography.mat not found\n\n');
end
% %% harris detektor, kontrola track_init
% 
% if  (exist('track_init','file') || exist('track_init_klt','file') )
%     imgPrev = im2double(imread('cameraman.tif')); [h w]=size(imgPrev);
%     options.sigma_d = 1; options.sigma_i = 1.5; options.thresh = 0.080^4;  options.klt_window = 5; options.ps = 11;
%     options.ROI = [1 1 h w];
%     if exist('track_init_klt','file') xPrev = track_init_klt(imgPrev,options);
%     else xPrev = track_init(imgPrev,options); end
%     fprintf('Found %d harris points.\n\n',length(xPrev.x));
%     figure; imagesc(imgPrev); colormap gray; axis image; showPoints(xPrev);title('Harris detektor, sigma_d 1, sigma_i 1.5');
% else
%     fprintf('track_init.m not implemented\n\n');
% end
%% kontrola sledovani

    cv09; method = 'klt'; % spusti vase vlastni nastaveni parametru, ale s upravenou, testovaci processMpvVideo
    data.xRect =  [ 90  90 140 140]; data.yRect =  [ 30  80  80  30];
    options.ROI = [ 20  10 216 216];
    options.klt_show_steps = 0;
    imgPrev = im2double(imread('cameraman.tif')); [h w]=size(imgPrev);
    if exist(['track_init_' method],'file') xPrev = feval(['track_init_' method],imgPrev,options);
    else xPrev = track_init(imgPrev,options); end
    fprintf('Found %d points of interest.\n\n',length(xPrev.x));
     A = [ 1  0 -5; 0  1 -2;  0  0  1];
     tmp = A \ [ data.xRect; data.yRect; ones(1,length(data.xRect)) ];
     dataRef.xRect = tmp(1,:) ./ tmp(3,:); dataRef.yRect = tmp(2,:) ./ tmp(3,:);
     [x y] = meshgrid((1:w)-1,(1:h)-1);   
     imgNew = interp2(imgPrev, A(1,1)*x+A(1,2)*y+A(1,3)+1, A(2,1)*x+A(2,2)*y+A(2,3)+1);
     xNew = feval(['track_' method],imgPrev,imgNew,xPrev,options);
    figure; imagesc(imgPrev); colormap gray; axis image; showPoints(xPrev);
    line([data.xRect data.xRect(1)],[data.yRect data.yRect(1)], 'color', 'y');
    title('imgNew with the original rectangle');
    % find a homography
    figure;
    [dataOut xNewOut] = processMpvFrame(data,imgPrev,imgNew,xPrev,xNew,options);
    showPoints(xNew);
    line([dataRef.xRect dataRef.xRect(1)],[dataRef.yRect dataRef.yRect(1)], 'color', 'y');
    title('imgPrev with the transformed rectangle');
    % plot results
    fprintf('Found %d inliers %.2f percent of tentative correspondences.\n\n', length(xNewOut.ID), 100*length(xNewOut.ID)/length(xNew.ID));
    H = inv(dataOut.H / dataOut.H(3,3));
    fprintf('Original transformation matrix:\n'); disp(A / A(3,3));
    fprintf('Your homography matrix:\n'); disp(H / H(3,3));
    fprintf('Referece rectangle:\n'); disp([dataRef.xRect; dataRef.yRect]);
    fprintf('Your transformed rectangle:\n'); disp([dataOut.xRect; dataOut.yRect]);
    fprintf('Transformation error:\n'); disp([dataRef.xRect - dataOut.xRect; dataRef.yRect - dataOut.yRect]);
    
%% Convergence test Harris
    options.klt_show_steps = 1;
    options.klt_window = 20;
    figure;
    xPrev.x = 47; xPrev.y = 126; xPrev.ID = 4;
    xNew = feval(['track_' method],imgPrev,imgNew,xPrev,options);
    fprintf('Estimated translation: x=%2.2f y=%2.2f\n',xNew.x-xPrev.x,xNew.y-xPrev.y);
%% Divergence test Harris       
    figure;
    xPrev.x = 153; xPrev.y = 64; xPrev.ID = 38;
    xNew = feval(['track_' method],imgPrev,imgNew,xPrev,options);
    fprintf('Estimated translation: x=%2.2f y=%2.2f\n',xNew.x-xPrev.x,xNew.y-xPrev.y);
%% Sythetic convergence test on a linear image   
    figure;
    w = 100; h = 50; [X Y] = meshgrid(1:w,1:h);
    imgPrev = (X + 2*Y) ./ (w+2*h); imgPrev = [imgPrev; flipud(imgPrev)];
    [x y] = meshgrid((1:w)-1,(1:2*h)-1); 
    imgNew = interp2(imgPrev, A(1,1)*x+A(1,2)*y+A(1,3)+1, A(2,1)*x+A(2,2)*y+A(2,3)+1);
    xPrev.x = w*0.6; xPrev.y = h; xPrev.ID = 1;
    xNew = feval(['track_' method],imgPrev,imgNew,xPrev,options);
    fprintf('Estimated translation: x=%2.2f y=%2.2f\n',xNew.x-xPrev.x,xNew.y-xPrev.y);
