% JN Kather 2018
% this script will load whole slide image files, thumbnail image files and
% ROI files as specified in the structure cnst (constants)
% WTRB = *W*hole slide images, *T*humbnails, *R*egions of interest, *B*locks

function fileCollection = loadFilesWTRB(cnst)

disp(['welcome to project ',cnst.ProjectName]);

% ensure that a ROI folder exists
[~,~,~] = mkdir(cnst.folderName.ROI);

try % try to load whole slide images
fileCollection.WSI = imageDatastore(cnst.folderName.WSI, ... % load WSIs
    'IncludeSubfolders',true,'FileExtensions',cnst.fileformat.WSI,'LabelSource','foldernames');  
disp(['I found ',num2str(numel(fileCollection.WSI.Files)),' WSI files']);
catch
    warning('did not find whole slide images (WSI) .. will continue');
end
try % try to load additional thumbnail images
fileCollection.Thumb = imageDatastore(cnst.folderName.Thumb, ... % load Thumbs
    'IncludeSubfolders',true,'FileExtensions',cnst.fileformat.Thumb,'LabelSource','foldernames');  
catch
    fileCollection.Thumb = [];
end
try % try to load existing regions of interest
fileCollection.ROI = imageDatastore(cnst.folderName.ROI, ... % load ROIs
    'IncludeSubfolders',true,'FileExtensions',cnst.fileformat.ROI,'LabelSource','foldernames');  
catch
    disp('did not find any compatible ROI files for this project');
    fileCollection.ROI = [];
end
try % try to load existing blocks
    disp('--- starting to load Blocks');
    tic
    fileCollection.Blocks = imageDatastore(cnst.folderName.Blocks, ... % load ROIs
        'IncludeSubfolders',true,'FileExtensions',cnst.fileformat.Blocks,'LabelSource','foldernames');  
    toc
    fileCollection.Blocks.Labels = repmat(categorical({''}),numel(fileCollection.Blocks.Labels),1); % remove labels
    disp(['I found ',num2str(numel(fileCollection.Blocks.Files)),' Block files']);
catch
    disp('could not load any previous Blocks ... will proceed');
    fileCollection.Blocks = [];
end

end