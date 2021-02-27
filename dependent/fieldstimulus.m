function ObjStim = fieldstimulus()
    
    QUERY = ['SELECT stimulusid, shortdescr FROM stimulus' ];    
    Rec =  mysql(QUERY);

    ObjStim.stimulus = '';
    ObjStim.shortdescr = '';
    
    h = 450;
    F = figure('menu', 'none', 'toolbar', 'none');
    F.Position = [300 200 600 600];
    
    uicontrol(F, 'Style','text', 'Position',[20,h+90,360,20], 'FontSize', 12, 'HorizontalAlignment', 'left', 'String', 'Enter values for new stimulus' );
    uicontrol(F, 'Style','text', 'Position',[20,h+60,200,20], 'String', 'Name (<30 characters)');
    CntrName = uicontrol(F, 'Style','edit', 'Position',[220 h+60,300,20], 'Callback', @Cb );
    uicontrol(F, 'Style','text', 'Position',[20,h+30,200,20], 'String', 'Short description (<160 characters)');
    CntrDescr = uicontrol(F, 'Style','edit', 'Position',[220, h+30, 300,20], 'Callback', @Cb );

    uicontrol(F, 'Style','text', 'Position',[20,h,360,20], 'FontSize', 12, 'HorizontalAlignment', 'left', 'String', 'or select existing stimulus from table')
    t = uitable('Parent', F, 'ColumnWidth',{150 300}, 'ColumnName',{'Name'; 'shortdescription'}, 'Data', Rec, 'CellSelectionCallback', @Cbtbl );
    t.Position(3:4) = [500 400];
    t.Position(2) = t.Position(2) + 20;
    
    uicontrol(F, 'Style','pushbutton', 'Position',[360, 10, 70, 25], 'String', 'done', 'Callback', 'uiresume(gcbf)');
    uicontrol(F, 'Style','pushbutton', 'Position',[440, 10, 70, 25], 'String', 'cancel', 'Callback', @Cancel);
    uiwait(gcf); 
    close(F)

  function Cancel(~,~)
      ObjStim = []; 
      uiresume(gcbf)
  end

  function Cb(src, ~)
    switch src  
        case CntrName                
            ObjStim.stimulus = src.String;
        case CntrDescr
            ObjStim.shortdescr = src.String;
    end
  end

  function Cbtbl(~, ev)
      %disp(ev.Indices)
      col = ev.Indices(1);
     CntrName.String = Rec{col,1};
     CntrDescr.String = Rec{col,2};
     
     ObjStim.stimulus = Rec{col,1};
     ObjStim.shortdescr = Rec{col,2};
  end

end

