// Feather disable all

/// Generates a barebones JSON schema from an input data structure. This is a handy way to quickly
/// create a schema that you can flesh out properly by hand.
/// 
/// N.B. Be sure to call `IagoAddInstanceOf()` if necessary before `IagoGenerate()`.
/// 
/// @param id
/// @param data
/// @param [allPropertiesRequired=true]

function IagoGenerate(_id, _data, _allPropertiesRequired = true, _title = undefined, _description = undefined)
{
    var _root = __IagoGenerateInner(_data, _allPropertiesRequired, true);
    _root[$ "$schema"] = "https://json-schema.org/draft/2020-12/schema";
    _root[$ "$id"    ] = _id;
    
    if (is_string(_title))
    {
        _root[$ "title"] = _title;
    }
    
    if (is_string(_description))
    {
        _root[$ "title"] = _description;
    }
    
    return _root;
}

function __IagoGenerateInner(_data, _allPropertiesRequired, _topLevel)
{
    static _idToIagoDict = __IagoSystem().__idToIagoDict;
    static _instanceOfDict = __IagoSystem().__instanceOfDict;
    
    var _member = {};
    
    if (is_array(_data))
    {
        _member.type = "array";
        
        if (array_length(_data) <= 0)
        {
            _member.items = {};
        }
        else
        {
            var _firstMember = __IagoGenerateInner(_data[0], _allPropertiesRequired, false);
            var _type = _firstMember[$ "type"];
            var _ref  = _firstMember[$ "$ref"];
            
            if ((_type != undefined) || (_ref != undefined))
            {
                var _i = 1;
                repeat(array_length(_data)-1)
                {
                    var _childMember = __IagoGenerateInner(_data[_i], _allPropertiesRequired, false);
                    var _childType = _childMember[$ "type"];
                    var _childRef  = _childMember[$ "$ref"];
                    
                    if (((_type != undefined) && (_childType != _type)) || ((_ref != undefined) && (_childRef != _ref)))
                    {
                        _type = undefined;
                        return;
                    }
                
                    ++_i;
                }
                
                if (_type != undefined)
                {
                    _member.items = {
                        type: _type,
                    };
                }
                else if (_ref != undefined)
                {
                    _member.items = {};
                    _member.items[$ "$ref"] = _ref;
                }
            }
        }
    }
    else if (is_method(_data))
    {
        //Methods count as structs for some reason so we have to handle them first
    }
    else if (is_struct(_data))
    {
        var _existingIago = undefined;
        
        if (not _topLevel)
        {
            var _existingID = _instanceOfDict[$ instanceof(_data)];
            if (_existingID != undefined)
            {
                _existingIago = _idToIagoDict[$ _existingID];
            }
        }
        
        if (_existingIago != undefined)
        {
            _member[$ "$ref"] = _existingID;
        }
        else
        {
            _member.type = "object";
            
            var _properties = {};
            _member.properties = _properties;
            
            var _namesArray = variable_struct_get_names(_data);
            
            if (_allPropertiesRequired)
            {
                array_sort(_namesArray, true);
                _member.required = _namesArray;
            }
            
            var _i = 0;
            repeat(array_length(_namesArray))
            {
                var _name = _namesArray[_i];
                _properties[$ _name] = __IagoGenerateInner(_data[$ _name], _allPropertiesRequired, false);
                ++_i;
            }
        }
    }
    else if (is_bool(_data))
    {
        _member.type = "boolean";
    }
    else if (is_numeric(_data))
    {
        //JSON doesn't differentiate between number types
        _member.type = "number";
    }
    else if (is_string(_data))
    {
        _member.type = "string";
    }
    else if (is_undefined(_data))
    {
        _member.type = "null";
    }
    else
    {
        //Some other type that is not JSON-compliant.
        //GameMaker will typically stringify these so ...
        _member.type = "string";
    }
    
    return _member;
}