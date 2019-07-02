% JN Kather 2019
% this script will load CLINI and SLIDE table and will load them and match
% them up after performing a sanity test

function tMERGE = getAnnotationData(cnst)

   % define internal params
   % empty cells will be converted to 'x'
   prm.removeTargets = categorical({'NA','NaN','N/A','na','n.a.','N.A.','undef','unknown','','x'});
   
   % read the clinical table and the slide table
   tCLINI = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.CliniTable),'Delimiter',',','ReadVariableNames',true);
   tSLIDE = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.SlideTable),'Delimiter',',','ReadVariableNames',true);

   % optional: subset clini table
   if isfield(cnst,'subsetTargets')
       disp('-- will start subsetting of target table (assumes subset level is a string)');   
       sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,cnst.subsetTargets.by)),'target variable subset exists');
       disp(['--- before subsetting, there are ',num2str(size(tCLINI,1)),' entries in the CLINI table']);   
       tCLINI(~strcmp(tCLINI.(cnst.subsetTargets.by),cnst.subsetTargets.level),:) = [];
       disp(['--- after subsetting, there are ',num2str(size(tCLINI,1)),' entries in the CLINI table']);     
   else
       disp('-- no subsetting of target table');
   end

   % perform basic sanity checks
   sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,'PATIENT')),'PATIENT column in CLINI');
   sanityCheck(any(strcmp(tSLIDE.Properties.VariableNames,'PATIENT')),'PATIENT column in SLIDE');
   sanityCheck(any(strcmp(tSLIDE.Properties.VariableNames,'FILENAME')),'FILENAME column in SLIDE');
   sanityCheck(numel(unique(tCLINI.PATIENT))==numel(tCLINI.PATIENT),'no duplicate patients CLINI');
   sanityCheck(numel(unique(tSLIDE.FILENAME))==numel(tSLIDE.FILENAME),'no duplicate filenames SLIDE');
   sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,cnst.annotation.targetCol)),'target variable CLINI');
   
   % are there patients with no slides?
   missCount = 0;
   for cp = 1:numel(tCLINI.PATIENT)
       currPatient = char(tCLINI.PATIENT(cp));
       if ~any(strcmp(tSLIDE.PATIENT,currPatient))
           disp(['--- did not find a slide table entry for patient ',currPatient]);
           missCount = missCount +1;
       end
   end
   disp(['-- there were ',num2str(missCount),' out of ',num2str(numel(tCLINI.PATIENT)),...
                ' patients without any slide table entry']);    
   
   % prepare merged table
   tMERGE.FILENAME = tSLIDE.FILENAME;
   if isnumeric(tMERGE.FILENAME)
       tMERGE.FILENAME = cellstr(num2str(tMERGE.FILENAME));
   end
   tMERGE.PATIENT  = tSLIDE.PATIENT;
   if isnumeric(tMERGE.PATIENT)
       tMERGE.PATIENT = cellstr(num2str(tMERGE.PATIENT));
   end
   
   targetData = tCLINI.(cnst.annotation.targetCol);
   if numel(unique(targetData))>5
       if isnumeric(targetData)
           targetData = targetData>=median(targetData, 'omitnan');
           disp('--- converted continuous target to binary');
       else
           try
           targetData = cellfun(@str2double,targetData);
           if sum(isnan(targetData))<numel(targetData) % if conversion worked
               removeMe = isnan(targetData);
               targetData = strrep(strrep(cellstr(num2str(double(targetData>=median(targetData, 'omitnan')))),'0','LO'),'1','HI');
               targetData(removeMe) = {'undef'};
               disp('--- numerized and then converted continuous target to binary');  
           else
               warning('--- conversion did not work, falling back.');
               targetData = tCLINI.(cnst.annotation.targetCol);
           end
           catch
               warning('could not convert target to numeric. Falling back.');
               targetData = tCLINI.(cnst.annotation.targetCol);
           end
       end
   end 

   if isnumeric(targetData)
        allTargets = categorical(targetData);
   else % make sure strings do not contain bad characters
       try
        allTargets = categorical(matlab.lang.makeValidName(targetData));
       catch
           warning('failed to make valid name');
       end
   end
   
   sanityCheck(numel(unique(allTargets))>1,'more than one target level');
   
   disp('found the following target levels: ');
   disp(cellstr(unique(allTargets)'));
   % match target variable to SLIDE table
   missCount = 0;
   for cp = 1:numel(tMERGE.PATIENT)
       currPatient = char(tMERGE.PATIENT(cp));
       matchPatClin = strcmp(tCLINI.PATIENT,currPatient);
       if matchPatClin == 0
           tMERGE.TARGET(cp) = categorical(NaN);
           disp(['-- could not match patient ',currPatient,', setting TARGET empty']);
           missCount = missCount +1;
       elseif matchPatClin>1
           error(['multiple matches for patient ',currPatient]);
       else % all is good
           tMERGE.TARGET(cp) = allTargets(matchPatClin);
       end
   end
   disp(['-- there were ',num2str(missCount),' out of ',num2str(numel(tSLIDE.PATIENT)),...
             ' patients with no match in CLINI table']);    
            
   % clean up target variable
   removeMe = find(isundefined(tMERGE.TARGET)); % remove missing targets
   for ct = 1:numel(prm.removeTargets)          % remove invalid targets
       removeMe = [removeMe(:);find(tMERGE.TARGET==prm.removeTargets(ct))'];
   end
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.PATIENT))),' patients']);
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.FILENAME))),' slides']);
   disp(['--- will remove ',num2str(numel(removeMe)),' slides']);
   tMERGE.PATIENT(removeMe) = [];
   tMERGE.FILENAME(removeMe) = [];
   tMERGE.TARGET(removeMe) = [];
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.PATIENT))),' patients']);
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.FILENAME))),' slides']);
   disp('the final table has the following target levels: ');
   disp(cellstr(unique(tMERGE.TARGET)));
end
