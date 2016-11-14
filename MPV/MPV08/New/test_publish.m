%test_publish

opt = [];
opt.format='html';
opt.imageFormat='jpeg';
opt.outputDir='output';
opt.figureSnapMethod='print';
opt.maxOutputLines=80;
opt.createThumbnail=false;
opt.useNewFigure=true;

publish('test.m', opt);