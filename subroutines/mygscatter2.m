function mygscatter2(x,y,g,s,alpha)

figure

gc = categorical(g);
[ugc,ugi,ugz] = unique(gc); 
colz = fliplr(lines(numel(ugc)));

for i=(1:numel(ugc))
    subplot(1,numel(ugc),i)
    mask = gc==ugc(i);
    sc = scatter(x(mask),y(mask),s,'filled');
    sc.MarkerFaceAlpha = alpha;
    sc.MarkerFaceColor = colz(i,:);
    title(cellstr(ugc(i)));
    axis square tight
    xlim([1,numel(x)]);
    ylim([0,1]);
    set(gca,'FontSize',14)
end

set(gcf,'Color','w');
set(gcf, 'Position',[ 0.9630    0.3877    1.0913    0.7573]*1000);
end
