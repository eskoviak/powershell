Add-Type -TypeDefinition @"
using System;

public class Activity{
    private String _name;

    public Activity(){
        _name = "New Activity";
    
    }

    public String Name {
        get { return _name; }
        set { this._name = value; }
    }
}
"@