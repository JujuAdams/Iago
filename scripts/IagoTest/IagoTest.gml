// Feather disable all

/// Tests whether the given input data conforms to the JSON schema. Returns `true` or `false`.
/// 
/// N.B. You should add all necessary IDs with `IagoAddID()` before calling `IagoTest()` or you
///      will encounter errors.
/// 
/// @param schema
/// @param data

function IagoTest(_schema, _data)
{
    return __IagoTestInner(_schema, _data);
}

function __IagoTestInner(_schema, _data)
{
    static _idToIagoDict = __IagoSystem().__idToIagoDict;
    
    var _ref = _schema[$ "$ref"];
    if (_ref != undefined)
    {
        _schema = _idToIagoDict[$ _ref];
        
        if (_schema == undefined)
        {
            __IagoError("Cannot find schema for reference \"{_ref}\"");
        }
    }
    
    var _type = _schema[$ "type"];
    if ((_type == undefined) || (_type == "any"))
    {
        return true;
    }
    else if (_type == "array")
    {
        if (not is_array(_data))
        {
            return false;
        }
        
        var _itemIago = _schema.items;
        var _i = 0;
        repeat(array_length(_data))
        {
            if (not __IagoTestInner(_itemIago, _data[_i]))
            {
                return false;
            }
            
            ++_i;
        }
        
        //All passed!
        return true;
    }
    else if (_type == "object")
    {
        if (not is_struct(_data))
        {
            return false;
        }
        
        var _required = _schema[$ "required"];
        if (is_array(_required))
        {
            var _nameArray = variable_struct_get_names(_data);
            array_sort(_required, true);
            array_sort(_nameArray, true);
            
            if (not array_equals(_required, _nameArray))
            {
                return false;
            }
        }
        
        var _properties = _schema.properties;
        var _nameArray = variable_struct_get_names(_properties);
        var _i = 0;
        repeat(array_length(_nameArray))
        {
            var _name = _nameArray[_i];
            
            if (not __IagoTestInner(_properties[$ _name], _data[$ _name]))
            {
                return false;
            }
            
            ++_i;
        }
        
        return true;
    }
    else if (_type == "boolean")
    {
        return is_bool(_data);
    }
    else if (_type == "number")
    {
        return is_numeric(_data);
    }
    else if (_type == "string")
    {
        return is_string(_data);
    }
    else if (_type == "null")
    {
        return is_undefined(_data);
    }
    else
    {
        __IagoError($"Unrecognised type \"{_type}\"");
    }
    
    //Fall through is FAILURE
    return false;
}