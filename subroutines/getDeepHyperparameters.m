
function hyperparam = getDeepHyperparameters(codename)

switch upper(codename)
    case 'DEFAULT'
        % specify learning parameters 
        hyperparam.InitialLearnRate = 1e-5; % initial learning rate
        hyperparam.ValidationFrequency = 256; % check validation performance every N iterations, 500 is 3x per epoch
        hyperparam.ValidationPatience = 3; % wait N times before abort
        hyperparam.L2Regularization = 1e-4; % optimization L2 constraint
        hyperparam.MiniBatchSize = 512;    % mini batch size, limited by GPU RAM, default 256 on P6000
        hyperparam.MaxEpochs = 100;           % max. epochs for training, default 100
        hyperparam.hotLayers = 10;        % how many layers from the end are not frozen
        hyperparam.learnRateFactor = 2; % learning rate factor for rewired layers
        hyperparam.ExecutionEnvironment = 'gpu'; % environment for training and classification
        hyperparam.PixelRangeShear = 5;  % max. shear (in pixels) for image augmenter
    otherwise
        error('invalid codename');
end

disp('-- successfully assigned deep hyperparameters');
end
