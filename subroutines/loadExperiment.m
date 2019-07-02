% JN Kather 2019

function cnst = loadExperiment(codename)

switch lower(codename)
    % -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
  
    case 'hnsc-on-acmachine'
        cnst.ProjectName    = 'TCGA-HNSC-DX';
        cnst.folderName.WSI = ''; % empty means generate on the fly
        cnst.folderName.Temp = 'D:\TEMP\';
        cnst.allTargets = {'HPV_status'};
        
  
    case 'stad-on-actitan'
        cnst.fileformat.Blocks = '.png';
        cnst.ProjectName    = 'TCGA_STAD_DX';
        cnst.folderName.WSI = 'G:\TCGA_DX_SEP\TCGA-STAD'; 
        cnst.folderName.Temp = 'E:\TEMP';
        cnst.allTargets = {'isEBV'};
    
    otherwise
        error('unspecified codename');
end
        
    % ensure consistent filenames
    cnst.folderName.WSI = fullfile(cnst.folderName.WSI);
    cnst.folderName.Temp = fullfile(cnst.folderName.Temp);
    
    rng('shuffle');
    cnst.experimentName = randseq(12,'Alphabet','aa');
    disp(['--- this is experiment # ',cnst.experimentName]);

end