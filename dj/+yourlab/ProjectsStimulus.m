%{
# projects_stimulus table
project : varchar(50)      # unique name
stimulus: varchar(50)
---
projectidx : int(3)
stimulusidx: int(3)
%}

classdef ProjectsStimulus < dj.Manual
end