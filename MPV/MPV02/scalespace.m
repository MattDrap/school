function [ss,sigma]=scalespace(img,levels,step)
%scalespace Summary of this function goes here
%   Detailed explanation goes here
    sigma = step.^[0:levels - 1];
    [H, W] = size(img);
    ss=zeros([H, W, levels]);
    ss(:,:,1)=img;

    for i = 2:levels
        x = [-ceil(3.0*sigma(i)):ceil(3.0*sigma(i))];
        G = gauss(x, sigma(i));
        G = G./sum(G);
        
        ss(:,:, i) = conv2(G, G, img, 'same');
    end

end

