function imdb = bacteria_trust_get_database(fmdDir, varargin)
opts.seed = 0 ;
opts = vl_argparse(opts, varargin) ;

rng(opts.seed, 'twister') ;

imdb.imageDir = fmdDir;

cats = dir(imdb.imageDir) ;
cats = cats([cats.isdir] & ~ismember({cats.name}, {'.','..'})) ;
imdb.classes.name = {cats.name} ;
imdb.images.id = [] ;

for c=1:numel(cats)
  ims = dir(fullfile(imdb.imageDir, imdb.classes.name{c}, '*.tif'));
  % if there is more then 20 images, then take only first 20 images
  if numel(ims) > 20
    ims = ims(1:20);
  end
  %imdb.images.name{c} = fullfile(imdb.classes.name{c}, {ims.name}) ;
  imdb.images.name{c} = cellfun(@(S) fullfile(imdb.classes.name{c}, S), ...
    {ims.name}, 'Uniform', 0);
  imdb.images.label{c} = c * ones(1,numel(ims)) ;
  if numel(ims) < 20, error('ops') ; end
  sets = [1 * ones(1,5), 2 * ones(1,5), 2 * ones(1,10)] ;
  imdb.images.set{c} = sets(randperm(20)) ;
end
imdb.images.name = horzcat(imdb.images.name{:}) ;
imdb.images.label = horzcat(imdb.images.label{:}) ;
imdb.images.set = horzcat(imdb.images.set{:}) ;
imdb.images.id = 1:numel(imdb.images.name) ;

imdb.segments = imdb.images ;
imdb.segments.imageId = imdb.images.id ;

imdb.segments.mask = cell(1, numel(imdb.segments.id)); % base are []
imdb.segments.bigMask = cell(1, numel(imdb.segments.id)); % only base are not empty
imdb.segments.baseImageId = imdb.segments.imageId;

testIndices = [...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Acinetobacter.baumanii_0005')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Actinomyces.israeli_0011')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Bacteroides.fragilis_0005')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Bifidobacterium.spp_0019')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Candida.albicans_0001')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Clostridium.perfringens_0007')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Enterococcus.faecalis_0003')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Enterococcus.faecium_0012')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Escherichia.coli_0016')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Fusobacterium_0001')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.casei_0007')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.crispatus_0001')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.delbrueckii_0005')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.gasseri_0003')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.jehnsenii_0012')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.johnsonii_0020')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.paracasei_0018')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.plantarum_0013')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.reuteri_0014')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.rhamnosus_0009')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Lactobacillus.salivarius_0014')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Listeria.monocytogenes_0013')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Micrococcus.spp_0005')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Neisseria.gonorrhoeae_0010')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Porfyromonas.gingivalis_0011')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Propionibacterium.acnes_0014')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Proteus_0009')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Pseudomonas.aeruginosa_0011')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Staphylococcus.aureus_0018')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Staphylococcus.epidermidis_0017')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Staphylococcus.saprophiticus_0020')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Streptococcus.agalactiae_0016')))), ...
  find(not(cellfun('isempty', strfind(imdb.images.name, 'Veionella_0010')))), ...
];

% segment masks for "should I trust you" purposes
for i=testIndices
  im = imread(fullfile(imdb.imageDir, imdb.images.name{i}));
  imGray = rgb2gray(im);
  imGrayErode = imerode(imGray, strel('sphere', 5));
  rng(831215);
  [mask, noSuperpixels] = superpixels(imGrayErode, 100);
  imdb.segments.bigMask{imdb.segments.imageId(i)} = mask;

  for r=1:1000
    rng(r);
    pos.smallMask = zeros(1, noSuperpixels);
    for m=1:noSuperpixels
      if rand > 0.9
        pos.smallMask(m) = 1;
      end
    end
    while sum(pos.smallMask) == 0
      for m=1:noSuperpixels
        if rand > 0.9
          pos.smallMask(m) = 1;
        end
      end
    end

    id = numel(imdb.segments.id) + 1;

    imdb.images.name(end+1) = imdb.images.name(i);
    imdb.images.label(end+1) = imdb.images.label(i);
    imdb.images.set(end+1) = 3;
    imdb.images.id(end+1) = id;

    imdb.segments.name(end+1) = imdb.segments.name(i);
    imdb.segments.label(end+1) = imdb.segments.label(i);
    imdb.segments.set(end+1) = 3;
    imdb.segments.id(end+1) = id;

    imdb.segments.imageId(end+1) = id;
    imdb.segments.mask{end+1} = pos;
    imdb.segments.baseImageId(end+1) = imdb.segments.imageId(i);
  end
end

% make this compatible with the OS imdb
imdb.meta.classes = imdb.classes.name ;
imdb.meta.inUse = true(1, numel(imdb.meta.classes)) ;
imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;
