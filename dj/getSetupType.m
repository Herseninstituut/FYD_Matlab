function type = getSetupType( setupname )

    global dbpar

    Database = dbpar.Database;  %= yourlab
    query = eval([Database '.Setups']); % setups table in FYD database for particular lab
    Sel = ['setupid= "' setupname '"'];
    setup = fetch(query & Sel, 'type');
    type = setup.type;