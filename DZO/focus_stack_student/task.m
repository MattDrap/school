
%MAX_IM_SIZE = Inf; % use for original image resolution 
MAX_IM_SIZE = 512; % use for fast code tuning/testing

WRITE_RESULT = 1; % write result as an image to the results/
                  % directory? 0/1

% select dataset: 
images_rootname = '86'; 
%images_rootname = 'kjz'; 

%for exponent = [1, 2, 3, 4, 6, 8]
for exponent = [2]

    % read input images: 
    im_rgb = read_rgb_images(fullfile('images', [images_rootname, '*']));

    % subsample if necessary: 
    if length(im_rgb{1}) > MAX_IM_SIZE
        im_rgb = cellfun(@(im) imresize(im, MAX_IM_SIZE/length(im)), im_rgb, 'UniformOutput', false);
    end

    imN = numel(im_rgb); 

    % convert to grayscale (for computing blending weights:) 
    im = cellfun( @(el) rgb2gray(el), im_rgb, 'UniformOutput', false); 

    % compute pyramids: 
    pyrs = cellfun( @(el) pyr_build(el), im, 'UniformOutput', false); 

    % create stack: 
    stack = stack_pyrs(pyrs); 

    % compute weights: 
    stack_weights = compute_weights(stack, exponent); 

    % finally, reconstruct image -- per channel: 
    out_im_rgb = zeros(size(im_rgb{1})); 

    for idx_channel = 1:3 
        % extract given channel: 
        for k=1:imN; im{k} = im_rgb{k}(:,:,idx_channel); end; 
    
        % compute pyramids: 
        pyrs = cellfun( @(el) pyr_build(el), im, 'UniformOutput', false); 

        % compute stack:
        stack = stack_pyrs(pyrs); 

        % blend pyramids using stack_weights:
        out_pyr = pyrs_blend(stack, stack_weights); 

        out_im_rgb(:,:,idx_channel) = ...
            pyr_reconstruct(out_pyr);
    end

    % transform to 0-1 range: 
    out_im_rgb = im_normalize(out_im_rgb); 

    % display the results: 
    close all; 

    figure()
    montage(reshape_for_montage(im_rgb))
    title('input images')
    
    figure()
    subplot(1, 2, 1); 
    % compute mean image over im_rgb: 
    im_rgb_mean = zeros(size(im_rgb{1})); 
    ax1 = gca(); 
    for k=1:imN; im_rgb_mean = im_rgb_mean + 1/imN*im_rgb{k}; end;  
    imshow(im_normalize(im_rgb_mean)); title('average over image stack')

    subplot(1, 2, 2); 
    imshow(out_im_rgb); title('Pyramid blend')
    ax2 = gca(); 
    % link axes for joint pan/zoom browsing: 
    linkaxes([ax1, ax2]); 

    if WRITE_RESULT
        imwrite(im_normalize(out_im_rgb), ['results/', images_rootname, '_exp', num2str(exponent), '.png']); 
    end
end % exponent
