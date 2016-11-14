function bbx=getbbx(imid, NAMES, opt)
     
   showimage(imid, NAMES, opt);
   h = imrect;
   position = wait(h);  
   position(3:4)=position(1:2)+position(3:4);
   bbx = position-1;
