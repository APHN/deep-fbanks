if ismac
  imageDir = '../../BigData/bacteria/data/';
else
  imageDir = '/media/bz/C4048A7D048A71EA/BigData/bacteria/data/';
end

cats = dir([imageDir, 'bacteria']) ;
cats = cats([cats.isdir] & ~ismember({cats.name}, {'.','..'})) ;
name = {cats.name} ;

for c=1:numel(cats)
  ims = dir(fullfile([imageDir, 'bacteria'], name{c}, '*.tif'));

  mkdir([imageDir, 'bacteriaGray/', ims(1).name(1:end-9)]);
  for i=1:numel(ims)
    im = imread([imageDir, 'bacteria/', ims(1).name(1:end-9), '/', ims(i).name]) ;
    imGray = uint8(mean(im, 3));

    imwrite(imGray, [imageDir, 'bacteriaGray/', ims(1).name(1:end-9), '/', ims(i).name]);
  end
end
