function letter_mean = compute_letter_mean(letter_char, Alphabet, images, labels)

    letter_mean = uint8(mean(images(:,:,labels == strfind(Alphabet, letter_char)),3))
    
end
