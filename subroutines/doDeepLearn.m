
function [outputSummary,trainedFullModel] = doDeepLearn(cnst,hyperprm,pretrainedNet,allBlocksLabeled,AnnData)

%% Body: split dataset in train-test and do the training
switch upper(cnst.trainMode)
    case 'XVAL'
        disp(['-- will start a ',num2str(cnst.foldxval),' fold cross validated experiment']);
        [imdsContainer,AnnData] = splitImdsForXVal(allBlocksLabeled,AnnData,cnst);
        sanityCheck(~gisempty(imdsContainer),'imds containers empty check');
        for ir = 1:cnst.foldxval
            disp(['--- starting crossval experiment ',num2str(ir)]);            
            
            % create image datastore for test set in this run
            imdsTST = imageDatastore(imdsContainer{ir}.Files);
            imdsTST.Labels = imdsContainer{ir}.Labels;
            disp(['--- there are ',num2str(numel(imdsTST.Files)),' blocks in the test set']);
            % create image datastore for training set in this run
            imdsTRN = copy(allBlocksLabeled);
            imdsTRN.Files(ismember(imdsTRN.Files,imdsTST.Files)) = []; % remove all test set files from the training set
            disp(['---- there are ',num2str(numel(imdsTRN.Files)),' blocks in the training set']);
            imdsTRN = equalizeClasses(imdsTRN); % undersample training set
            disp(['---- there are ',num2str(numel(imdsTRN.Files)),' blocks in the training set']);
            [trainedModel{ir},stats{ir}] = goTrainDeep(pretrainedNet,...
                imdsTRN,imdsTST,cnst,hyperprm);  
            stats{ir} = predictions2stats(stats{ir},imdsTST,AnnData,cnst);
            stats{ir} %#ok
        end
        
        % now re-train the classifier on the full image set so that it can
        % be deployed on another validation data set
        
        if cnst.trainFull
            disp('training on full set for external validation');
            [trainedFullModel,~] = goTrainDeep(pretrainedNet,...
                equalizeClasses(allBlocksLabeled),[],cnst,hyperprm);   
        else
            trainedFullModel = [];
        end
        
    case 'HOLDOUT'
        disp('-- will start a train and validate-on-holdout experiment');
        error('not yet implemented');
    case 'FULL'
        disp('-- will train on the full data set, no accuracy reported');
        error('not yet implemented');
    otherwise 
        error('undefined train mode');
end


% show results
allAUC = summarizeAndShow(AnnData,stats,cnst) %#ok

outputSummary.allAUC = allAUC;
outputSummary.stats = stats;

end
