// Feather disable all

function __IagoSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        __IagoTrace($"Welcome to Iago by Juju Adams! This is version {IAGO_VERSION}, {IAGO_DATE}");
        
        __idToIagoDict = {};
        __instanceOfDict = {};
    }
    
    return _system;
}