function  showKltStep(step,T,I,E,Gx,Gy,aP)
    figure(366);
    if (step == 0)
        clf;
    end    
    subplot(3,3,1);
    imagesc(T); colormap gray; axis image; title('T (xPrev patch)');
    subplot(3,3,4);
    imagesc(I); colormap gray; axis image; title('I (xNew patch)');
    subplot(3,3,5);
    imagesc(Gx); colormap gray; axis image; title('G_{x}');
    subplot(3,3,6);
    imagesc(Gy); colormap gray; axis image; title('G_{y}');
    subplot(3,3,7);
    imagesc(E); colormap gray; axis image; title('E');
    subplot(3,3,8);
    plot(step,aP,'Marker','x','MarkerSize',8,'LineWidth',2,'Color','r'); hold on; title('|\DeltaP|^2');
    subplot(3,3,9);
    plot(step,sum(sum(E.^2)),'Marker','x','MarkerSize',8,'LineWidth',2); hold on; title('sum(E^2)');
end