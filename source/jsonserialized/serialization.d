module jsonserialized.serialization;

import std.conv;
import stdx.data.json;
import std.traits;

@safe:

pure JSONValue serializeToJSONValue(T)(in ref T array) if (isArray!T) {
    JSONValue[] values;

    // Iterate each item in the array and add them to the array of JSON values
    foreach(item; array) {
        static if (is(ForeachType!T == struct)) {
            // This item is a struct
            values ~= item.serializeToJSONValue();
        }
        else static if (is(ForeachType!T == class)) {
            // This item is a class - serialize it unless it is null
            if (item !is null) {
                values ~= item.serializeToJSONValue();
            }
        }
        else static if (isSomeString!(ForeachType!T)) {
            values ~= JSONValue(item.to!string);
        }
        else static if (isArray!(ForeachType!T)) {
            // An array of arrays. Recursion time!
            values ~= item.serializeToJSONValue();
        }
        else {
            values ~= JSONValue(item);
        }
    }

    return JSONValue(values);
}

pure JSONValue serializeToJSONValue(T)(in ref T associativeArray) if (isAssociativeArray!T) {
    JSONValue[string] items;

    // Iterate each item in the associative array
    foreach(key, value; associativeArray) {
        // JSON keys have to be strings, so convert every key to a string
        auto stringKey = key.to!string;

        static if (is(ValueType!T == struct)) {
            // The value type is struct
            items[stringKey] = value.serializeToJSONValue();
        }
        else static if (is(ValueType!T == class)) {
            // The value is a class - serialize it unless it is null
            if (value !is null) {
                items[stringKey] = value.serializeToJSONValue();
            }
        }
        else static if (isAssociativeArray!(ValueType!T)) {
            /* The associative array's value type is another associative array type.
               It's recursion time. */
            items[stringKey] = value.serializeToJSONValue();
        }
        else static if (isSomeString!(ValueType!T)) {
            items[stringKey] = JSONValue(value.to!string);
        }
        else {
            items[stringKey] = JSONValue(value);
        }
    }

    return JSONValue(items);
}

pure JSONValue serializeToJSONValue(T)(in ref T obj) if (is(T == struct) || is(T == class)) {
    enum fieldNames = FieldNameTuple!T;

    JSONValue[string] jsonValues;

    foreach(fieldName; fieldNames) {
        auto field = __traits(getMember, obj, fieldName);
        alias FieldType = typeof(field);

        static if (is(FieldType == struct)) {
            // This field is a struct - recurse into it
            jsonValues[fieldName] = field.serializeToJSONValue();
        }
        else static if (is(FieldType == class)) {
            // This field is a class - recurse into it unless it is null
            if (field !is null) {
                jsonValues[fieldName] = field.serializeToJSONValue();
            }
        }
        else static if (isSomeString!FieldType) {
            // Because JSONValue only seems to work with string strings (and not char[], etc), convert all string types to string
            jsonValues[fieldName] = JSONValue(field.to!string);
        }
        else static if (isArray!FieldType) {
            // Field is an array
            jsonValues[fieldName] = field.serializeToJSONValue();
        }
        else static if (isAssociativeArray!FieldType) {
            // Field is an associative array
            jsonValues[fieldName] = field.serializeToJSONValue();
        }
        else {
            jsonValues[fieldName] = JSONValue(field);
        }
    }

    return JSONValue(jsonValues);
}
