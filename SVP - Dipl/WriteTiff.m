function [] = WriteTiff( filename, img, datatype)
%WriteTiff Writes multidimensional image img to a tiff file

if ~exist('datatype', 'var')
    datatype = 8;
end

tiffhandle = Tiff(filename, 'w');

tagstruct.BitsPerSample = datatype;
tagstruct.Compression = Tiff.Compression.LZW;
tagstruct.Orientation = 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;

tagstruct.ImageLength = size(img,1);
tagstruct.ImageWidth = size(img,2);
tagstruct.SamplesPerPixel = size(img, 3);
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tiffhandle.setTag(tagstruct);

tiffhandle.write(img);
tiffhandle.close();
end

