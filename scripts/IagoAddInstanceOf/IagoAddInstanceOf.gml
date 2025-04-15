// Feather disable all

/// Associates a schema ID with a GML `instanceof()` value. This is used when generating schemas
/// with `IagoGenerate()`. This function will not affect `IagoTest()` (and you'll very likely
/// want to call `IagoAddID()` to set up `IagoTest()`).
/// 
/// @param schemaOrID
/// @param instanceOfOrStruct

function IagoAddInstanceOf(_schemaOrID, _instanceOfOrStruct)
{
    static _instanceOfDict = __IagoSystem().__instanceOfDict;
    
    if (is_string(_instanceOfOrStruct))
    {
        //Good to go
    }
    else if (is_struct(_instanceOfOrStruct))
    {
        _instanceOfOrStruct = instanceof(_instanceOfOrStruct);
    }
    else
    {
        __IagoError("instanceof input must be a string or a struct");
    }
    
    if (is_string(_schemaOrID))
    {
        _instanceOfDict[$ _instanceOfOrStruct] = _schemaOrID;
    }
    else if (is_struct(_schemaOrID))
    {
        var _id = _schemaOrID[$ "$id"];
        if (not is_string(_id))
        {
            __IagoError("Iago has no `$id` property");
        }
        
        _instanceOfDict[$ _instanceOfOrStruct] = _id;
    }
    else
    {
        __IagoError("Iago input must be a string or a JSON schema");
    }
}