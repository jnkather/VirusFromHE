% JN Kather 2018
% this script will prepare everything for the deep image pipeline
% all constants will be set, subfolders included etc.

function [cnst,fCollect] = initializeDeepImagePipeline(codename,cnst)

if ~isfield(cnst,'nogpu')
    doGPUworkaround(); % this is needed for Ubuntu :-/
else
    disp('GPU not needed');
end

rng('default'); % reset random number generator for reproducibility
addpath(genpath('./subroutines_MELANIE/'));       % add additional dependencies

if ~isfield(cnst,'blocks') || ~isfield(cnst.blocks,'normalize')
    cnst.blocks.normalize = false;
end

if cnst.blocks.normalize % read the reference image for color-normalization
    cnst.refImage = imread('./resources/Ref.png');
    addpath(genpath('./subroutines_normalization/')); 
end

if isfield(cnst,'useNormalizedBlocks') && cnst.useNormalizedBlocks
    disp('loading normalized blocks');
    cnst.folderName.Blocks = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/BLOCKSNORM/'); % abs. path to block save folder
    [~,~,~] = mkdir(cnst.folderName.Blocks);
else
    disp('loading non-normalized blocks');
cnst.folderName.Blocks = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/BLOCKS/'); % abs. path to block save folder
    [~,~,~] = mkdir(cnst.folderName.Blocks);
end
    
cnst.folderName.Dump = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/DUMP/'); % abs. path to block save folder
    [~,~,~] = mkdir(cnst.folderName.Dump);
cnst.folderName.Fail = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/FAIL/'); % abs. path to block save folder
    [~,~,~] = mkdir(cnst.folderName.Fail);

if ~isfield(cnst.folderName,'Thumb') % by default, take the same as the image folder
    cnst.folderName.Thumb = cnst.folderName.WSI; % abs. path to thumbnail fallback folder
end
    
cnst.fileformat.WSI =   {'.svs'}; % define file format for WSI
cnst.fileformat.Thumb = {'.tiff','.tif'}; % define file format for thumbnail
cnst.fileformat.ROI =   '.csv';           % define format for ROI
if ~isfield(cnst.fileformat,'Blocks')
cnst.fileformat.Blocks ='.png';     % define format for Blocks
end
cnst.blocks.sizeOnImage     = 512; % block size on whole slide image in px
if ~isfield(cnst.blocks,'normalize')
cnst.blocks.normalize       = false; % color-normalize blocks while cutting, default false
end
cnst.blocks.storeSize       = 512; % size to store the blocks
cnst.blocks.NeuralInputSize = 224; % block will be resized to this size
cnst.blocks.targetMPP       = 0.5; % microns per pixel, default 0.5
cnst.blocks.maxBlockNum     = 3000; % maximum number of blocks per whole slide image
cnst.blocks.rescueString    = '_001'; % blocks that were manually rescued because of the JPEG2000 issue have this string...
cnst.maxColor               = 4;   % maximum color for block tissue class
cnst.aggregateMode = 'majority';   % how to pool block predictions per patient, 'majority', 'mean' or 'max'

if ~isfield(cnst,'foldxval')
cnst.foldxval               = 3;   % if cross validation is used, this is the fold
end
cnst.nBootstrapAUC          = 5; % bootstrap for AUC confidence interval, default 5
cnst.useParallel            = false; % use parallel processing for blockproc
% we cannot use parallel for SVS images because blockproc parallel does not
% support the ImageAdapter class :-(

switch upper(codename)
    case 'MELANIE' % MELANIE = seMiautomatic dEep LeArniNg pIplinE
        disp('preparing ROI folder for MELANIE');
        cnst.folderName.ROI = fullfile([cnst.folderName.WSI,'/MELANIE_ROIs/']);       
    case 'FELIPE'  % FELIPE = Fully automatic dEep LearnIng PipelinE
        disp('preparing tumor detectors for FELIPE');
        % locate and load previously trained tumor detector
    otherwise
        error('undefined codename');
end

fCollect = loadFilesWTRB(cnst); % load files for WSI, Thumbs, ROI, Blocks
printDecoration(codename); % print decoration to command line
end