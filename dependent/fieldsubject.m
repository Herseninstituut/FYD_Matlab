function ObjSub = fieldsubject()

    QUERY = ['SELECT subjectid, species, sex, genotype FROM subjects' ];    
    Rec =  mysql(QUERY);

    ObjSub.subject = '';
    ObjSub.species = 'mouse';
    ObjSub.sex = 'U';
    ObjSub.genotype = 'none';
    
    species = {'mouse', 'monkey', 'human'};
    sex = {'U', 'M', 'F'};
    
    h = 360;
    F = figure('menu', 'none', 'toolbar', 'none');
    F.Position = [300 200 460 540];
    
    uicontrol(F, 'Style','text', 'Position',[20,h+150,360,20], 'FontSize', 12, 'String', 'Enter values for new subject' );
    uicontrol(F, 'Style','text', 'Position',[20,h+120,200,20], 'String', 'Name');
    CntrName = uicontrol(F, 'Style','edit', 'Position',[220 h+120,120,20], 'Callback', @Cb );
    uicontrol(F, 'Style','text', 'Position',[20,h+90,200,20], 'String', 'Species');
    CntrSpec = uicontrol(F, 'Style','popupmenu', 'string', species, 'Position',[220, h+90, 120, 20], 'Callback', @Cb );   
   
    uicontrol(F, 'Style','text', 'Position',[20,h+60,200,20], 'String', 'Sex (M, F, U)');
    CntrSex = uicontrol(F, 'Style','popupmenu', 'string', sex, 'Value', 1, 'Position',[220, h+60, 120,20], 'Callback', @Cb );
    
    uicontrol(F, 'Style','text', 'Position',[20,h+30,200,20], 'String', 'Genotype');
    CntrGeno = uicontrol(F, 'Style','edit', 'Position',[220, h+30, 120,20], 'Callback', @Cb );
    uicontrol(F, 'Style','text', 'Position',[20,h,360,20], 'FontSize', 12, 'String', 'or select existing subject from table')
    t = uitable('Parent', F, 'ColumnWidth','auto', 'ColumnName',{'Name'; 'species'; 'sex'; 'genotype' }, 'Data', Rec, 'CellSelectionCallback', @Cbtbl );
    t.Position(3) = t.Extent(3) + 15;
    t.Position(2) = t.Position(2) + 20;
    
    uicontrol(F, 'Style','pushbutton', 'Position',[200, 10, 70, 25], 'String', 'done', 'Callback', 'uiresume(gcbf)');
    uicontrol(F, 'Style','pushbutton', 'Position',[280, 10, 70, 25], 'String', 'cancel', 'Callback', @Cancel );
    uiwait(gcf); 
    close(F)

  function Cancel(~,~)
      ObjSub = []; 
      uiresume(gcbf)
  end

  function Cb(src, ~)
    switch src  
        case CntrName                
            ObjSub.subject = src.String;
        case CntrSpec
            ObjSub.species = species{src.Value};
        case CntrSex
            ObjSub.sex = sex{src.Value};
        case CntrGeno
            ObjSub.genotype = src.String;
    end
  end

  function Cbtbl(~, ev)
      %disp(ev.Indices)
      col = ev.Indices(1);
     CntrName.String = Rec{col,1};
     CntrSpec.String = Rec{col,2};
     CntrSex.String = Rec{col,3};
     CntrGeno.String = Rec{col,4};
     
     ObjSub.subject = Rec{col,1};
     ObjSub.species = Rec{col,2};
     ObjSub.sex = Rec{col,3};
     ObjSub.genotype = Rec{col,4};
  end

end

