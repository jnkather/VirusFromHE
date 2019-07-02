% JN Kather 2019
% return AUC for each class on a patient level

function [patientPredictions,patientStats] = ...
                aggregateStatsPerPatient(imdsTST,stats,AnnData,cnst)

    % for each block (tile), find the corresponding slide file name
    allFileNames = imdsTST.Files;
    % remove rescue string from block name
    disp('--- erasing rescue string from block names');
    allFileNames = erase(allFileNames,cnst.blocks.rescueString);
    allFileNames = block2filename(allFileNames);
    
    % iterate all true slide names and find corresponding tiles
    allAnnDataFiles = AnnData.FILENAME;
    for i = 1:numel(allAnnDataFiles)
        matchFile = contains(allFileNames,allAnnDataFiles{i});
        allPatientNames(matchFile) = AnnData.PATIENT(i);
    end
        
    % get true target value for each patient
    uPats = unique(allPatientNames); % unique patients
    uCats = unique(AnnData.TARGET);  % unique target categories
    for i = 1:numel(uPats)
        patientPredictions.patientNames(i) = uPats(i);
        % find true category of this patient
        currTrueCategory = AnnData.TARGET(strcmp(AnnData.PATIENT,uPats{i}));
        if numel(currTrueCategory)>1 % if there were >1 slide, check their labels match
            sanityCheck(numel(unique(currTrueCategory))==1,'>1 slide with matching labels');
        end
        patientPredictions.trueCategory(i) = currTrueCategory(1);
        % which target value has been predicted?
        currLabels = stats.blockStats.PLabels(strcmp(allPatientNames,uPats{i}));
        currScores = stats.blockStats.Scores(strcmp(allPatientNames,uPats{i}),:);
        for uc = 1:numel(uCats)
            if isfield(cnst,'aggregateMode') & strcmp(cnst.aggregateMode,'mean')
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    mean(double(currScores(:,uc)));
            elseif isfield(cnst,'aggregateMode') & strcmp(cnst.aggregateMode,'max')
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    max(double(currScores(:,uc)));     
            else % majority vote
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    sum(currLabels==uCats(uc))/numel(currLabels);
            end
        end
    end
    
    % go from predictions to statistics
    for uc = 1:numel(uCats) % AUC for each class
        [X,Y,T,AUC,OPTROCPT,SUBY,SUBYNAMES] = ...
            perfcurve(patientPredictions.trueCategory,...
               patientPredictions.predictions.(char(uCats(uc))),uCats(uc),...
                    'NBoot',cnst.nBootstrapAUC);
        patientStats.AUC.(char(uCats(uc))) = AUC;
        patientStats.Plot.X = X;
        patientStats.Plot.Y = Y;
    end
end
