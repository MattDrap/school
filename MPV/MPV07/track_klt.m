function xNew = track_klt(imgPrev,imgNew,xPrev,options)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[Height,Width] = size(imgNew);

[AGx,AGy]= gaussderiv(imgNew, options.sigmai); % gradient estimation

xNew = struct('x',[],'y',[],'ID',[],'data',[]);
pCounter = 1;
for i = 1:length(xPrev.x)
    p = [0;0];
    ap = [Inf; Inf];
    step = 0;
    T = getPatchSubpix(imgPrev, xPrev.x(i), xPrev.y(i), options.klt_window , options.klt_window);
    
    while sum(ap.^2) > options.klt_stop_treshold && step < options.klt_stop_count
        if (round(xPrev.x(i)) < 1) || (round(xPrev.y(i)) < 1) || (round(xPrev.x(i)) > Width) || (round(xPrev.y(i)) > Height)
            step = Inf;
            break;
        end
        I = getPatchSubpix(imgNew, xPrev.x(i) + p(1), xPrev.y(i) + p(2), options.klt_window , options.klt_window);
        if isnan(I)
            step = Inf;
            break;
        end
        E = I - T;
        dIx =  getPatchSubpix(AGx, xPrev.x(i) + p(1), xPrev.y(i) + p(2), options.klt_window , options.klt_window);
        dIy =  getPatchSubpix(AGy, xPrev.x(i) + p(1), xPrev.y(i) + p(2), options.klt_window , options.klt_window);
        g = [ dIx(:) dIy(:) ];
        H = g'*g; % approximation of hessian matrix with dot product
        ap = inv(H)*(g'*E(:));
        p = p - ap;
        step = step + 1;
        
        if (options.klt_show_steps)
          showKltStep(step,T,I,E,dIx,dIy,ap);
         end
         % step  - serial number of iteration (zero based)
         % T     - template, (patch from imgPrev)
         % I     - current sifted patch in imgNew
         % E     - current error (I - T)
         % Gx,Gy - gradients
         % aP    - size of current shift delta P
    end
    nx = xPrev.x(i) + p(1);
    ny = xPrev.y(i) + p(2);
    if step <= options.klt_stop_count
        if (nx > 0 && nx <= Width) && ...
            (ny > 0 && ny <= Height)
            xNew.x(pCounter) = nx;
            xNew.y(pCounter) = ny;
            xNew.ID(pCounter) = xPrev.ID(i);
            pCounter = pCounter + 1;
        end
    end
end
xNew.x = xNew.x';
xNew.y = xNew.y';
xNew.ID = xNew.ID';
end



