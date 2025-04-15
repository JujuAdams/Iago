// Feather disable all

/// Tests whether the given input data conforms to the JSON schema. Returns `true` or `false`.
/// 
/// N.B. You should add all necessary IDs with `IagoAddID()` before calling `IagoTest()` or you
///      will encounter errors.
/// 
/// N.B. The `pattern` keyword for string types is not supported.
/// 
/// @param schema
/// @param data

function IagoTest(_schema, _data)
{
    var _schemaVersion = _schema[$ "$schema"];
    if (_schemaVersion != IAGO_TARGET_VERSION)
    {
        __IagoError($"Schema version \"{_schemaVersion}\" not supported\nPlease set `IAGO_PERMISSIVE` to `true` to disable this error");
    }
    
    return __IagoTestInner(undefined, _schema, _data, undefined);
}

function __IagoTestInner(_parentSchema, _schema, _data, _forceType)
{
    static _idToIagoDict = __IagoSystem().__idToIagoDict;
    
    var _ref = _schema[$ "$ref"];
    if (_ref != undefined)
    {
        _schema = (_ref == "#")? _parentSchema : _idToIagoDict[$ _ref];
        if (_schema == undefined) __IagoError($"Cannot find schema for reference \"{_ref}\"");
    }
    
    if (variable_struct_exists(_schema, "format"))
    {
        __IagoTrace("Warning! \"format\" keyword is not supported");
    }
    
    var _type = _forceType ?? _schema[$ "type"];
    if (_type == undefined)
    {
        var _enum = _schema[$ "enum"];
        if (is_array(_enum))
        {
            var _i = 0;
            repeat(array_length(_enum))
            {
                if (__IagoEquals(_enum[_i], _data))
                {
                    return true;
                }
                
                ++_i;
            }
            
            return false;
        }
        else if (variable_struct_exists(_schema, "const"))
        {
            return __IagoEquals(_schema[$ "const"], _data);
        }
        else
        {
            _type = "any";
        }
    }
    
    if (_type == "any")
    {
        return true;
    }
    else if (_type == "array")
    {
        if (not is_array(_data))
        {
            return false;
        }
        
        if (variable_struct_exists(_schema, "unevaluatedProperties"))
        {
            __IagoTrace("Warning! \"unevaluatedProperties\" keyword is not supported");
        }
        
        var _dataLength = array_length(_data);
        
        var _minItems = _schema[$ "minItems"] ?? 0;
        var _maxItems = _schema[$ "maxItems"] ?? infinity;
        if ((_dataLength < _minItems) || (_dataLength > _maxItems)) return false;
        
        if (_schema[$ "uniqueItems"] ?? false)
        {
            if (array_length(array_unique(_data)) != _dataLength) return false;
        }
        
        var _tupleSchema = _schema[$ "prefixItems"];
        var _listSchema  = _schema[$ "items"];
        
        var _i = 0;
        if (is_array(_tupleSchema))
        {
            if (array_length(_tupleSchema) > _dataLength)
            {
                //Length mismatch
                return false;
            }
            
            repeat(array_length(_tupleSchema))
            {
                if (not __IagoTestInner(_schema, _tupleSchema[_i], _data[_i], undefined))
                {
                    return false;
                }
                
                ++_i;
            }
        }
        
        if (is_struct(_listSchema))
        {
            repeat(_dataLength - _i)
            {
                if (not __IagoTestInner(_schema, _listSchema, _data[_i], undefined))
                {
                    return false;
                }
                
                ++_i;
            }
        }
        
        var _containsSchema = _schema[$ "contains"];
        if (_containsSchema != undefined)
        {
            var _minContains = _schema[$ "minContains"] ?? 1;
            var _maxContains = _schema[$ "maxContains"] ?? infinity;
            
            var _passed = 0;
            var _i = 0;
            repeat(_dataLength)
            {
                if (__IagoTestInner(_schema, _containsSchema, _data[_i], undefined))
                {
                    ++_passed;
                    //TODO - Early out here if it's not possible to meet the minimum threshold
                    if (_passed > _maxContains) return false;
                }
                
                ++_i;
            }
            
            if (_passed >= _minContains)
            {
                return false;
            }
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
        
        if (variable_struct_exists(_schema, "$anchor"))
        {
            __IagoTrace("Warning! \"$anchor\" keyword is not supported (yet)");
        }
        
        if (variable_struct_exists(_schema, "$defs"))
        {
            __IagoTrace("Warning! \"$defs\" keyword is not supported (yet)");
        }
        
        if (variable_struct_exists(_schema, "patternProperties"))
        {
            __IagoTrace("Warning! \"patternProperties\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "unevaluatedProperties"))
        {
            __IagoTrace("Warning! \"unevaluatedProperties\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "dependentRequired"))
        {
            __IagoTrace("Warning! \"dependentRequired\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "dependentSchemas"))
        {
            __IagoTrace("Warning! \"dependentSchemas\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "allOf"))
        {
            __IagoTrace("Warning! \"allOf\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "anyOf"))
        {
            __IagoTrace("Warning! \"anyOf\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "not"))
        {
            __IagoTrace("Warning! \"not\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "if"))
        {
            __IagoTrace("Warning! \"if\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "then"))
        {
            __IagoTrace("Warning! \"then\" keyword is not supported");
        }
        
        if (variable_struct_exists(_schema, "else"))
        {
            __IagoTrace("Warning! \"else\" keyword is not supported");
        }
        
        var _minProperties = _schema[$ "minProperties"] ?? 0;
        var _maxProperties = _schema[$ "maxProperties"] ?? infinity;
        var _dataLength = variable_struct_names_count(_data);
        if ((_dataLength < _minProperties) || (_dataLength > _maxProperties))
        {
            return false;
        }
        
        var _dataNameArray = undefined;
        
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
        
        var _properties           = _schema[$ "properties"];
        var _additionalProperties = _schema[$ "additionalProperties"] ?? true;
        
        if (is_bool(_additionalProperties) && (not _additionalProperties))
        {
            if ((not is_struct(_properties)) || (variable_struct_names_count(_properties) > variable_struct_names_count(_data)))
            {
                return false;
            }
        }
        
        if (is_struct(_properties))
        {
            var _propertyNameArray = variable_struct_get_names(_properties);
            var _i = 0;
            repeat(array_length(_propertyNameArray))
            {
                var _name = _propertyNameArray[_i];
                
                if (not __IagoTestInner(_schema, _properties[$ _name], _data[$ _name], undefined))
                {
                    return false;
                }
                
                ++_i;
            }
        }
        
        if (is_struct(_additionalProperties))
        {
            _dataNameArray = _dataNameArray ?? variable_struct_get_names(_data);
            var _i = 0;
            repeat(array_length(_dataNameArray))
            {
                var _name = _dataNameArray[_i];
                if ((_properties == undefined) || (not variable_struct_exists(_properties, _name)))
                {
                    if (not __IagoTestInner(_schema, _additionalProperties, _data[$ _name], undefined))
                    {
                        return false;
                    }
                }
                
                ++_i;
            }
        }
        
        var _propertyNamesSchema = _schema[$ "propertyNames"];
        if (is_struct(_propertyNamesSchema))
        {
            _dataNameArray = _dataNameArray ?? variable_struct_get_names(_data);
            var _i = 0;
            repeat(array_length(_dataNameArray))
            {
                if (not __IagoTestInner(_schema, _propertyNamesSchema, _dataNameArray[_i], "string"))
                {
                    return false;
                }
                
                ++_i;
            }
        }
        
        return true;
    }
    else if (_type == "boolean")
    {
        return is_bool(_data);
    }
    else if (_type == "number")
    {
        if (not is_numeric(_data)) return false;
        
        var _multipleOf = _schema[$ "multipleOf"];
        if (_multipleOf != undefined)
        {
            if ((_data / _multipleOf) != floor(_data / _multipleOf)) return false;
        }
        
        var _minimum = _schema[$ "minimum"] ?? -infinity;
        var _maximum = _schema[$ "maximum"] ??  infinity;
        var _exclusiveMinimum = _schema[$ "exclusiveMinimum"] ?? -infinity;
        var _exclusiveMaximum = _schema[$ "exclusiveMaximum"] ??  infinity;
        
        if ((_data <= _minimum)
        ||  (_data >= _maximum)
        ||  (_data < _exclusiveMinimum)
        ||  (_data > _exclusiveMaximum))
        {
            return false;
        }
        
        return true;
    }
    else if (_type == "string")
    {
        if (not is_string(_data)) return false;
        
        if (variable_struct_exists(_schema, "pattern"))
        {
            __IagoTrace("Warning! \"pattern\" keyword not supported");
        }
        
        var _minimum = _schema[$ "minLength"];
        var _maximum = _schema[$ "maxLength"];
        
        if ((_minimum != undefined) || (_maximum != undefined))
        {
            //Don't calculate the string length unless we have to
            var _length = string_length(_data);
            if ((_length < (_minimum ?? 0)) || (_length > (_maximum ?? infinity))) return false;
        }
        
        return true;
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