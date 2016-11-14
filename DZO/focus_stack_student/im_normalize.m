function im = im_normalize(im)
im = im - min(im(:)); 
im = im / max(im(:)); 

