%{
# projects_stimulus table
project : varchar(50)      # unique name
projectidx : int(3)
stimulus: varchar(50)
stimulusidx: int(3)
---
%}

classdef ProjectsStimulus < dj.Manual
end