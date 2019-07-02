function nameOut = stripID(nameIn,sep)
    myHits =[];
    for i=1:numel(sep)
        myHits = [myHits,strfind(nameIn,sep(i))];
    end
    
    nameOut = nameIn(1:(max(myHits)-1));
end