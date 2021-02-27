function record = mysqlselect(db, varargin)

DB = db.Database;
TBL = db.Tbl;

if nargin == 1 
        %select all; 11 columns in Imagedb
      QUERY = ['SELECT * FROM ' TBL];
       
else
    fldnms = varargin{1};
    if isempty(fldnms)
        QUERY = ['SELECT * FROM ' TBL];
    else
        
        SelStr = [];
        for i = 1:length(fldnms)-1
            SelStr = [SelStr fldnms{i} ', '];
        end
        SelStr = [SelStr fldnms{length(fldnms)}];
        
        QUERY = ['SELECT ' SelStr ' FROM ' TBL];
    end
    
    %SELECT * FROM users where id in (1,2,3,4,5);
    if length(varargin) == 2 %WHERE clause
        strwhere = varargin{2};
        QUERY = [QUERY ' WHERE ' strwhere];
        
    elseif nargin > 3    
        error('msqlselect:argChk', 'Wrong number of input arguments')
    end
end


dbimg = mysql('open', db.Server, db.User, db.Passw);
mysql('use', DB);
record = mysql(QUERY);
mysql('close')

   



