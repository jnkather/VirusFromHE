function tableOut = readMyTCGAdata(classIn,fileIn)

    try
        tableOut = readtable(['./cliniData/raw_data_2018_gdc_data_portal/',classIn,'/',fileIn,'.csv'],...
            'TreatAsEmpty',{'not reported','--','NA','missing','[Discrepancy]','[Not Available]'},'Delimiter','\t');
    catch
        error(['unable to read ', fileIn, ' of class ', classIn]);
    end
    
    % typecast data type for age at diagnosis
    if strcmp(fileIn,'clinical')
    tableOut.year_of_birth = uint8(tableOut.year_of_birth);
    tableOut.year_of_death = uint8(tableOut.year_of_death);
    tableOut.age_at_diagnosis = int32(tableOut.age_at_diagnosis);
    tableOut.days_to_death = double(tableOut.days_to_death);
    tableOut.days_to_birth = int32(tableOut.days_to_birth);
    tableOut.days_to_last_follow_up = double(tableOut.days_to_last_follow_up);
    
    % creat additional vars
    tableOut.hasDied = strcmp(tableOut.vital_status,'dead');
    
    % be very careful here as "stage i" also matches "stage iv"
    stage4 = contains(tableOut.tumor_stage,'stage iv');
    stage3 = contains(tableOut.tumor_stage,'stage iii');
    stage2 = contains(tableOut.tumor_stage,'stage ii');
    stage1 = contains(tableOut.tumor_stage,'stage i');
    
    cleanStage = nan(size(stage4));
    cleanStage(stage4) = 4;
    cleanStage(stage3) = 3;
    cleanStage(stage2 & ~stage3) = 2;
    cleanStage(stage1 & ~stage2 & ~stage3 & ~stage4) = 1;
    
    tableOut.cleanStage = cleanStage;
    end
end