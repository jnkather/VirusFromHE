function outName = filename2TCGAID(currName)

% extract patient ID from TCGA format string
dash = strfind(currName,'-');
outName = currName(1:(dash(3)-1));

end