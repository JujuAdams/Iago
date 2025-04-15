// Feather disable all

/// Adds a schema to the library in global scope. This will convert `$ref` links to schemas when
/// testing data.
/// 
/// N.B. Iago does not yet support bundling.
/// 
/// @param schema

function IagoAddID(_schema)
{
    static _idToIagoDict = __IagoSystem().__idToIagoDict;
    
    if (not is_struct(_schema))
    {
        __IagoError("Iago must be a struct");
    }
    
    var _id = _schema[$ "$id"];
    if (not is_string(_id))
    {
        __IagoError("Iago has no `$id` property");
    }
    
    //TODO - Support bundling
    
    _idToIagoDict[$ _id] = _schema;
}