function mygscatter(x,y,g,s)

gc = categorical(g);
ugc = unique(gc); %categorical({'EFF','TUM'}); % 
hold on
for i=1:numel(ugc)
    mask = gc==ugc(i);
    sc = scatter(x(mask),y(mask),s,'filled');
  %  sc.CData = [sc.CData,0.5];
end
legend(cellstr(ugc),'Location','WestOutside')
axis square tight
end
