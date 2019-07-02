% JN Kather 2018
% matlab's gscatter function sucks. This is a better implementation that
% allows you to change alpha and other options
% datagroup is categorical

function h = betterGscatter(xdata,ydata,msize,datagroup,dalpha)
    
    ugroup = unique(datagroup);
    mcolor = hsv(numel(ugroup));
    hold on
    for i=1:numel(ugroup)
        subs = (datagroup==ugroup(i));
        sc = scatter(xdata(subs),ydata(subs),msize,mcolor(i,:),'filled');
        set(sc,'MarkerFaceAlpha',dalpha);
        h{i} =sc;
    end
    hold off
    
    legend(cellstr(ugroup),'Location','EastOutside')

end