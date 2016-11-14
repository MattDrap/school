function [dataOut, xNewOut] = processMpvFrame(data,imgPrev,imgNew,xPrev,xNew,options)
%PROCESSMPVFRAME processing of the tracked frames
% Input:
%  data      structure with data for processing
%  imgPrev   previous frame of video sequence
%  imgNew    actual frame of video sequence
%  xPrev     tracking points in the previous frame
%  xNew      tracking points in the actual frame
%  options   stucture with parameters for specific tracking method
% 
% Output:
%  dataOut   precessed data
%  xNewOut   updated points in the actual frame

%TODO:
    
    % find homography
    indice = false(1, length(xPrev.x));
    for i = 1:length(xPrev.ID)
        if sum(xPrev.ID(i) == xNew.ID)
            indice(i) = true;
        end
    end
    u(1:2,:)=[[xPrev.x(indice)'] ; 
             [xPrev.y(indice)']];
    u(3,:)=1;
    u(4:5,:)=[[xNew.x'] ; 
             [xNew.y']];
    u(6,:)=1;

    [mH, minlH]=ransac_h(u, options.rnsc_threshold, options.rnsc_confidence);
    mH = mH./mH(3,3);
    Hbest = mH;
    
    % transform rectangle, update dataOut and with respect to outlayers
    ndata = Hbest * [data.xRect; data.yRect; ones(1, 4)];
    ndata = bsxfun(@rdivide, ndata, ndata(3, :));
    
    dataOut = data;
    dataOut.xRect = ndata(1, :);
    dataOut.yRect = ndata(2, :);
    
    xNew.x = xNew.x(minlH);
    xNew.y = xNew.y(minlH);
    %xNew.data = xNew.data(minlH);
    xNew.ID = xNew.ID(minlH);
    xNewOut = xNew;

    dataOut.H = Hbest;  %please, store homography to data structure for checking as well
    
    % get patch form imgNew
    patch = zeros(round(max(ndata(2, :))) - round(min(ndata(2, :))), round(max(ndata(1, :))) - round(min(ndata(1, :))));
    for k = round(min(ndata(2, :))):round(max(ndata(2, :)))
        for l = round(min(ndata(1, :))):round(max(ndata(1, :)))
            if inpolygon(l, k, ndata(1, :), ndata(2, :))
                patch(k - round(min(ndata(2, :))) + 1, l - round(min(ndata(1, :)))+ 1) = imgNew(k, l);
            end
        end
    end
    %patch = imgNew(round(min(ndata(2, :))):round(max(ndata(2, :))), round(min(ndata(1, :)):round(max(ndata(1, :)))));
    % blur the patch
    patch = gaussfilter(patch, 5);
    
    imgProc = imgNew;
    % plot it back into imgProc
    for k = round(min(ndata(2, :))):round(max(ndata(2, :)))
        for l = round(min(ndata(1, :))):round(max(ndata(1, :)))
            if inpolygon(l, k, ndata(1, :), ndata(2, :))
                imgProc(k, l) = patch(k - round(min(ndata(2, :))) + 1, l - round(min(ndata(1, :)))+ 1);
            end
        end
    end
    %imgProc(round(min(ndata(2, :))):round(max(ndata(2, :))), round(min(ndata(1, :)):round(max(ndata(1, :))))) = patch;
    % plot image into the actual figure
        
    imagesc(imgProc); colormap gray; axis image;
    hold on;
    
    line([dataOut.xRect dataOut.xRect(1)],[dataOut.yRect dataOut.yRect(1)], 'color', 'm');

end