%{
# Huub's lab Journal
# add primary key here
sessionid   : varchar(100)
-----
# add additional attributes
url     :   varchar(500)
project :   varchar(50)
dataset :   varchar(50)
excond   : varchar(30)
subject :   varchar(30)
date    :   date
setup   :   varchar(30)
stimulus    : varchar(50)
screen_distance : int
stim_time       : float
comment = '' :   varchar(500) 
%}

classdef Huub < dj.Manual
end