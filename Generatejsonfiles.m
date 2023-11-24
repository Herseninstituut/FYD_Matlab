%% import json file records from Excel sheets 
% export json files to their locations

 [fn, fp] = uigetfile('*.xlsx');  
 strfp = fullfile(fp, fn);

T = readtable(strfp);

for i = 1:height(T)
    
    %generates filename from sessionid and concatenates with _session.json
    fn = [ T{i,'sessionid'}{1} '_session.json' ];
    strpath = fullfile( T{i,'path'}{1}, fn);
    
    %create data structure for fyd
   json.version = '1.0';
   json.project = T{i,'project'}{1};
   json.dataset = T{i,'dataset'}{1};
   json.subject = T{i,'subject'}{1};
   json.stimulus = T{i,'stimulus'}{1};
   json.condition = T{i,'condition'}{1};
   json.setup = T{i,'setup'}{1};
   json.investigator = T{i,'investigator'}{1};
   json.date = num2str(T{i,'date'});
   
   %encodes structure to json formatted text.
    txtO = jsonencode(json);
    fid = fopen(strpath, 'w');
    fwrite(fid, txtO);
    fclose(fid);
     
end

