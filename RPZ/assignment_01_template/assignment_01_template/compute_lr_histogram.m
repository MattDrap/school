function lr_histogram = compute_lr_histogram(letter_char, Alphabet, images, labels, num_bins)
    l_images = images(:,:,labels == strfind(Alphabet, letter_char));
    x = sum(sum(l_images(:,1:end/2,:),1),2) - sum(sum(l_images(:,end/2 + 1:end,:),1),2);
    x = x(:);
    lr_histogram = hist(x, num_bins);
end
