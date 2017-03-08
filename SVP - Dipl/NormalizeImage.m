function [ OutputImage ] = NormalizeImage( SourceImage, TargetImage )
%NormalizeImage Adjust SourceImage histogram such that it is same as in
%TargetImage
OutputImage = SourceImage;
[~,~,SC] = size(SourceImage);
for i = 1:SC
    aux = SourceImage(:,:,i);
    aux2 = TargetImage(:,:,i);
    OutputImage(:,:,i) = histeq(aux, hist(aux2));
end

