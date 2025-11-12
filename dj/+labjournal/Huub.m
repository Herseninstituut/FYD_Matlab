%{
# Huub's lab Journal
# add primary key here
sessionid   : varchar(100)
-----
# add additional attributes
url     :   varchar(500)
dataset :   varchar(50)
excond   : varchar(30)
subject :   varchar(30)
genotype = null: varchar(20)
sex = 'U' : enum('M', 'F', 'U') 
age = null : varchar(30)        # age : days, weeks, months, years
hemisphere = null : enum('l', 'r', 'u')   # which hemisphere
location = null  : varchar(60) 
date    :   date
setup   :   varchar(30)
stimulus    : varchar(50)
screen_distance = null : int
stim_time  = null     : float
comment = '' :   varchar(500) 
%}

classdef Huub < dj.Manual
end