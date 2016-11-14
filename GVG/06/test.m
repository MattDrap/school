for k = 1:3
    image = images{k+2};
    for i = round(min(bbxpoints(2, (k-1)*4+1:k*4))):round(max(bbxpoints(2, (k-1)*4+1:k*4)))
        for j = round(min(bbxpoints(1, (k-1)*4+1:k*4))):round(max(bbxpoints(1, (k-1)*4+1:k*4)))
            coords = H{4, k+2}*[j; i; 1];
            coords(1) = round(coords(1)/coords(3));
            coords(2) = round(coords(2)/coords(3));
            if coords(2) < 1 || coords(2) > 900
                continue;
            end
            if coords(1) < 1 || coords(1) > 1200
                continue;
            end
            panorama1(i - mins(2), j - mins(1), :) = image(coords(2), coords(1), :);
        end
    end
end