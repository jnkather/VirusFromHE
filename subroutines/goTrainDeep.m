% JN Kather 2019

function [postNet,stats] = ...
    goTrainDeep(preNet,imdsTRN,imdsTST,cnst,hyperprm)          
    
    if isempty(imdsTST)
    disp([newline,'-- starting the training with ',num2str(numel(imdsTRN.Files)),...
        ' training blocks NO test blocks']);
    else
    disp(['-- starting the training with ',num2str(numel(imdsTRN.Files)),...
        ' training blocks and ',num2str(numel(imdsTST.Files)),' test blocks']);
    end
    
    % split the training images into a true training set of 85%, a validation
    % set to avoid overfitting during the training stage and a test
    % set which is currently not being used. This split is happening on
    % the level of image tiles, so the validation performance does not
    % inform us about the performance on a patient level
    rng('default');
    [internalTRN, internalVLD] = splitEachLabel(imdsTRN,.9,.1,'randomized');
    
    % prepare data augmenter
    trainingAugmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true,...
        'RandXTranslation',[-hyperprm.PixelRangeShear,hyperprm.PixelRangeShear],...
        'RandYTranslation',[-hyperprm.PixelRangeShear,hyperprm.PixelRangeShear]);
    internalTRN_AUG = augmentedImageDatastore(preNet.imageInputSize,...
        internalTRN,'DataAugmentation',trainingAugmenter);
    internalVLD_AUG = augmentedImageDatastore(preNet.imageInputSize,...
        internalVLD); % resize validation images, no augmentation
    opts = getTrainingOptions(hyperprm,internalVLD_AUG);
    
    t = tic;
    if ~cnst.simulate
        try
        postNet = trainNetwork(internalTRN_AUG, preNet.lgraph, opts);
        catch
            whos
             warning('ERROR DURING TRAINING');
        end 
    else
        postNet = [];
    end
    stats.trainTime = toc(t);
    
    if ~isempty(imdsTST) && ~cnst.simulate % evaluate test set
        externalTST_AUG = augmentedImageDatastore(preNet.imageInputSize,imdsTST); 
        [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(postNet, ...
            externalTST_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment);
        stats.blockStats.Accuracy = mean(stats.blockStats.PLabels == imdsTST.Labels);
        if cnst.verbose
            plotMyConfusion(imdsTST.Labels,stats.blockStats.PLabels); % plot confusion matrix
            title(strrep(cnst.ProjectName,'_','-'));
        end
    else % no test set defined, so cannot return any stats
        stats.blockStats = [];
    end        
end
