
function stats = predictions2stats(stats,imdsTST,AnnData,cnst)

    if ~isempty(imdsTST) && ~cnst.simulate % evaluated test set
        % aggregate scores on a patient level
        [stats.patientPredictions,stats.patientStats] = ...
            aggregateStatsPerPatient(imdsTST,stats,AnnData,cnst);
    else % no test set defined, so cannot return any stats
        disp('warning: there is no test set, will not return stats');
        stats.patientPredictions = [];
        stats.patientStats = [];
    end
    
end