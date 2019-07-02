% JN Kather Aachen / Chicago 2019
% this script is part of the digital pathology deep learning project
% MELANIE = seMiautomatic dEep LeArniNg pIplinE
%
%         Step 1: open all SVS images and draw regions
%         Step 2: cut the ROIs into blocks
% THIS IS Step 3: load blocks, train/test OR crossvalidate then train on all
%
% we need two tables:
% the SLIDE table associates SLIDES (images) to PATIENTS
% the CLINI table associates PATIENTS to outcome
% 
% we can do three types of experiments
% XVAL:     train and test by cross validation, then train on the full set
% HOLDOUT:  perform one split, hold out a test set
% FULL:     directly train on the full set, do not report accuracy
% cnst = loadExperiment('hnsc-on-pearson');
% for HOLDOUT, we can provide a list of patients in the test set or create it
% on the fly
%
% all splits will be done on a PATIENT level, so there will never be a
% contamination of the test set by tiles from a patient in the training set
%
%
% to do in the future: 
% - use adam instead of stochastic gradient descent
%
%% Header
clear variables, format compact, close all; clc % clean up
setenv CUDA_VISIBLE_DEVICES 0 % use only first GPU
gpuDevice(1)
addpath(genpath('./subroutines/'));  % add dependencies
cnst = loadExperiment('hnsc-on-actitan');

% load deep learning hyperparameters and  initialize deep learning model
hyperprm = getDeepHyperparameters('default');
hyperprm.ExecutionEnvironment = 'gpu';
hyperprm.MiniBatchSize = 150; 
hyperprm.ValidationFrequency = 256;
hyperprm.ValidationPatience = 2;
hyperprm.MaxEpochs = 4;              %    4  more than 4 is not usually helpful because of overfitting (stops at 4 anyway)
hyperprm.InitialLearnRate =  1e-4;    %    1e-4
hyperprm.hotLayers = 10;              %    20

[cnst,fCollect] = initializeDeepImagePipeline('MELANIE',cnst); % initialize

% -------- START DEBUG --------
% cnst.blocks.maxBlockNum = 1000;
% -------- END DEBUG --------

deeplearnit() % startup output
cnst.verbose  = false;    % show intermediary steps?
cnst.simulate = false;   % simulate only? default false (-> do it!)
cnst.trainFull = false; % after xval, train on the full set for ext validation
cnst.trainMode = 'XVAL'; % XVAL or HOLDOUD or FULL
cnst.modelTemplate = 'resnet18'; % choose model template
% define SLIDE table and CLINI table
% the SLIDE table needs to have the columns FILENAME and PATIENT
% the CLINI table needs to have the column PATIENT plus an target column
cnst.annotation.Dir = './cliniData/';
cnst.annotation.SlideTable = [cnst.ProjectName,'_SLIDE.csv'];
cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.csv'];

for ti = 1:numel(cnst.allTargets) 
     
    allBlocksLabeled{ti} = duplicateImageDatastore(fCollect.Blocks);
    cnst.annotation.targetCol = char(cnst.allTargets{ti}); 
    disp([newline,newline,'#################',newline,newline,...
        'starting new experiment: ',cnst.annotation.targetCol ]);
    z1 = tic;
     try
        % read target data for this variable
        AnnData = getAnnotationData(cnst); 
        % load image tiles and match a target category to each tile 
        [allBlocksLabeled{ti}, AnnData, unmatchedBlocks] = loadImageTiles(allBlocksLabeled{ti},AnnData,cnst);
        % load the pretrained network
        pretrainedNet = getAndModifyNet(cnst,hyperprm,numel(unique(allBlocksLabeled{ti}.Labels))); 
        [resultCollection{ti},finalModel] = doDeepLearn(cnst,hyperprm,pretrainedNet,allBlocksLabeled{ti},AnnData);
        % add some more results
        resultCollection{ti}.unmatchedBlocks = unmatchedBlocks;
     catch
         warning('encountered severe error during training... wait 5 sec then continue');
         save(['lastError_',cnst.experimentName,'.mat']); % save workspace
         pause(5);
     end
        totalTime = toc(z1);
        resultCollection{ti}.cnst = cnst;
        resultCollection{ti}.hyperprm = hyperprm;
        resultCollection{ti}.totalTime = totalTime;
        % save results
        try
        % save results
        save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastResult.mat']),'resultCollection');
        save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastModel.mat']),'finalModel');
        catch
            warning('save error');
        end
end
    
