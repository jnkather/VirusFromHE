% JN Kather 2019, image datastore is empty

function anyIsEmpty = gisempty(inp)

anyIsEmpty = 0;

for i=1:numel(inp)
    anyIsEmpty = [anyIsEmpty,isempty(inp{i}.Files)];
end
        
anyIsEmpty = any(anyIsEmpty);
end