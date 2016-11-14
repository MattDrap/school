function processMpvVideo(filename,method,options)
%PROCESSMPVVIDEO processing video file for tracking
% Synopsis:
%  xPrev = track_init(imgPrev,ROI,options);
%  xNew = track_method(imgPrev,imgNew,xPrev,options);
%
% Input:
%  filename  string with the name of input file. String '000' in the filename
%    is replaced by sequence number of each image
%  method    string with the name of the tracking method used
%  options   stucture with parameters for synopsis method
% 

PATH_WRITE = '.\export\';
if (~exist(PATH_WRITE,'dir'))
    mkdir(PATH_WRITE);
end    

FRAME_LIMIT_B = 0;
FRAME_LIMIT_E = inf;

imgPrev = imread(regexprep(filename, '000', sprintf('%03d',FRAME_LIMIT_B)));
imgPrev = im2double(rgb2gray(imgPrev));

xHistory = struct('x',[],'y',[],'ID',[]);

fig = figure(342);
clf;

data = processMpvInit(imgPrev, options);

if exist(['track_init_' method],'file') 
    xPrev = feval(['track_init_' method],imgPrev,options);
else
    xPrev = track_init(imgPrev,options);
end

xHistory.x = [xHistory.x xPrev.x];
xHistory.y = [xHistory.y xPrev.y];
xHistory.ID = [xHistory.ID xPrev.ID];
    
hHistory = cell(FRAME_LIMIT_B-FRAME_LIMIT_E,1);

for frame_number = FRAME_LIMIT_B+1 : FRAME_LIMIT_E

    % get a new frame and make it black/white
    fileFrame = regexprep(filename, '000', sprintf('%03d', frame_number));
    if (~exist(fileFrame,'file'))
        break;
    end;    
    imgNew = imread(fileFrame);
    imgNew = im2double(rgb2gray(imgNew));

    % tracking using 
    xNew = feval(['track_' method],imgPrev,imgNew,xPrev,options);
    
    % create tracks 
    xHistory.x = [xHistory.x; xNew.x];
    xHistory.y = [xHistory.y; xNew.y];
    xHistory.ID = [xHistory.ID; xNew.ID];

    % visuialize them in figure 342
    fig = figure(342);
    clf;
    imagesc(imgNew); colormap gray; axis image;
    hold on;

    %plot points
    plot(xNew.x,xNew(:).y,'Color',hsv2rgb(0,0.9,1),'Marker','x','LineStyle','none');

    %plot tracks
    IDs = unique(xHistory.ID);
    for ID = IDs'
        mask = (xHistory.ID == ID);
        plot(xHistory.x(mask),xHistory.y(mask),'Color',hsv2rgb(0.1,0.8,1),'LineWidth',1,'Marker','none');
    end

    % figere captured into images
    fig = figure(343);
    clf;
    
    data = processMpvFrame(data,imgPrev,imgNew,xPrev,xNew,options);
    
    hHistory(frame_number-FRAME_LIMIT_B) = {data.H};
        
    % export figure to image
    F = getframe(fig);
    fileExport = regexprep(filename, '000', sprintf('%03d', frame_number));
    [pathstr, name, ext, versn] = fileparts(fileExport); 
    imwrite(F.cdata,[PATH_WRITE 'export_' name '.jpeg'],'jpeg','Quality',95);
    
    % prepare it for the new frame
    imgPrev = imgNew;
    xPrev = xNew;
    
end

save([PATH_WRITE 'homography.mat'], 'hHistory', 'xHistory');

end