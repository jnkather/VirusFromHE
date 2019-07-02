
function allAUC = summarizeAndShow(AnnData,stats,cnst)

    ucats = unique(AnnData.TARGET);
    if numel(stats) == 1
            for uc = 1:numel(ucats)
                allAUC(1,uc,:) = stats.patientStats.AUC.(char(ucats(uc)));
            end
    else
        for i = 1:numel(stats)
            for uc = 1:numel(ucats)
                allAUC(i,uc,:) = stats{i}.patientStats.AUC.(char(ucats(uc)));
            end
        end
    end
    
    if cnst.verbose
        figure
        imagesc(allAUC(:,:,1))
        colorbar
        colormap(hot(255))
        caxis([0.5,1]);
        axis equal tight
        set(gca,'XTick',1:numel(stats))
        set(gca,'YTick',1:numel(ucats))
        set(gca,'YTickLabel',cellstr(ucats))
        xlabel('cross validation runs');
        ylabel('AUC for category');
        set(gcf,'Color','w')
        title(strrep(['classifier performance for ',cnst.ProjectName],'_','-'));    
    end
end
