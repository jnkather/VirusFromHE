% JN Kather 2019

function [allBlocks,AnnData,unmatchedBlockNames] = loadImageTiles(allBlocks,AnnData,cnst)

    disp('-- starting to parse all whole slide image names, overwriting block labels... ');
    
    allBlockFileNames = allBlocks.Files;  % all block names
    % reset all block labels
    allBlocks.Labels = repmat(categorical(cellstr('UNDEF')),1,numel(allBlocks.Labels));
    disp('--- erasing rescue string from block names');
    allBlockFileNames = erase(allBlockFileNames,cnst.blocks.rescueString);
    
    numImages = numel(AnnData.FILENAME);
    
    sanityCheck(numel(AnnData.FILENAME)==numel(AnnData.TARGET),'each image has a target label');
    
    for ci = 1:numImages
        currImageName = AnnData.FILENAME{ci};
        matchingBlocks = contains(allBlockFileNames,currImageName);
        % optional: cap at N blocks
        if isfield(cnst.blocks,'maxBlockNum') & sum(matchingBlocks)>cnst.blocks.maxBlockNum
            disp(['---- will remove ',num2str(sum(matchingBlocks)-cnst.blocks.maxBlockNum),' excess blocks']);
            matchingBlocks = removeExcessIndices(matchingBlocks,cnst.blocks.maxBlockNum);
        else
            disp(['---- will not remove any blocks for this WSI']);
        end
        disp(['--- matched ',num2str(sum(matchingBlocks)),' blocks to ', currImageName]);
        AnnData.NUMBLOCKS(ci) = sum(matchingBlocks);
        if any(matchingBlocks) % overwrite block labels
            allBlocks.Labels(matchingBlocks) = AnnData.TARGET(ci);
        end
    end
    disp([newline,'-- found ', num2str(sum(AnnData.NUMBLOCKS==0)),' whole slide image(s) without any matching blocks']);
    
    removeMe = (AnnData.NUMBLOCKS==0);
    for cfn = fieldnames(AnnData)'
        AnnData.(char(cfn))(removeMe) = [];
    end
    
    disp(['---- (I have removed these whole slide images,',...
        ' remaining whole slide images with >0 blocks: ',num2str(numel(AnnData.FILENAME))]);
    
    % remove all Blocks without a label
    disp(['--- there are ',num2str(numel(allBlocks.Files)),' blocks in total']);
    disp('--- removing unlabeled blocks');
    unmatched = (allBlocks.Labels==categorical(cellstr('UNDEF'))) | isundefined(allBlocks.Labels);
    unmatchedBlockNames = allBlocks.Files(unmatched);
    allBlocks.Files(unmatched) = [];
    disp(['--- after cleanup, there are ',num2str(numel(allBlocks.Files)),' blocks in total']);
    
    % --- fix a Matlab bug by which the UNDEF category is preservedeven if
    % no element is undef (convert back and forth)
    allBlocks.Labels = categorical(cellstr(allBlocks.Labels));
    
end