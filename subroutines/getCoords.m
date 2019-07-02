% JN Kather 2017 NCT Heidelberg
% cut an image into the defined number of blocks
% returns start coords for cutting

function [xCoords, yCoords] = getCoords(imSize,targetBlocksize)
    
    targetBlocksize = targetBlocksize + 1;
    
    % find out number of blocks
    numXblocks = floor(imSize(1)/targetBlocksize);
    numYblocks = floor(imSize(2)/targetBlocksize);
    
    % find sum of blocksizes
    XblockSum = numXblocks * targetBlocksize;
    YblockSum = numYblocks * targetBlocksize;
    
    % find start coordinate
    XstartCoord = 1+floor((imSize(1)-XblockSum)/2);
    YstartCoord = 1+floor((imSize(2)-YblockSum)/2);
    
    % iterate x blocks
    for i = 1:numXblocks
        xCoords(i) = XstartCoord+(i-1)*targetBlocksize;
    end
    
    % iterate y blocks
    for i = 1:numYblocks
        yCoords(i) = YstartCoord+(i-1)*targetBlocksize;
    end
    
end

% clc, imSize = [1000 1000]; targetBlocksize = 750; [xCoords yCoords] = getCoords(imSize,targetBlocksize)