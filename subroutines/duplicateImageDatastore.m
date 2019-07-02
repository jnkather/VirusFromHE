% JN Kather 2019

function imdsOut = duplicateImageDatastore(imdsIn)
    disp('--- starting to duplicate image datastore');
    %tic
    %imdsOut = imageDatastore(imdsIn.Files);
    %imdsOut.Labels = imdsIn.Labels;
    %toc
    imdsOut = copy(imdsIn);
    disp('--- successfully duplicated this image datastore');
end