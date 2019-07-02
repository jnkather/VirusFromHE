% JN Kather 2019

function ids = splitList(listLength,numParts,randSeed)

    if numParts<=listLength
        disp('--- there are more patients than partitions in this group... good.');
        % create group ID list
        ids = repmat(1:numParts,1,ceil(listLength/numParts));
    else
        warning('there are fewer patients than partitions in this group ... be very careful');
        ids = 1:listLength;
    end

    % shuffle list
    rng(randSeed);
    ids = ids(randperm(numel(ids)));
    % make target length
    ids = ids(1:listLength);
   
end