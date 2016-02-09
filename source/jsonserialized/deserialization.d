module jsonserialized.deserialization;

import std.conv;
import stdx.data.json;
import std.traits;

@safe:

pure void deserializeFromJSONValue(T)(ref T array, in JSONValue jsonValue) if (isArray!T) {
    // Iterate each item in the array JSONValue and add them to values, converting them to the actual type
    foreach(jvItem; jsonValue.get!(JSONValue[])) {
        static if (is(ForeachType!T == struct)) {
            // This item is a struct - instantiate it
            ForeachType!T newStruct;

            // ...deserialize into the new instance
            newStruct.deserializeFromJSONValue(jvItem);

            // ...and add it to the array
            array ~= newStruct;
        }
        else static if (isSomeString!(ForeachType!T)) {
            array ~= jvItem.get!string.to!(ForeachType!T);
        }
        else static if (isArray!(ForeachType!T)) {
            // An array of arrays. Recursion time!
            ForeachType!T subArray;

            subArray.deserializeFromJSONValue(jvItem);
            array ~= subArray;
        }
        else {
            array ~= jvItem.to!(ForeachType!T);
        }
    }
}

pure void deserializeFromJSONValue(T)(ref T associativeArray, in JSONValue jsonValue) if (isAssociativeArray!T) {
    // Iterate each item in the JSON object
    foreach(stringKey, value; jsonValue.get!(JSONValue[string])) {
        auto key = stringKey.to!(KeyType!T);

        static if (isAssociativeArray!(ValueType!T)) {
            /* The associative array's value type is another associative array type.
               It's recursion time. */

            if (key in associativeArray) {
                associativeArray[key].deserializeFromJSONValue(value);
            }
            else {
                ValueType!T subAssocArray;

                subAssocArray.deserializeFromJSONValue(value);
                associativeArray[key] = subAssocArray;
            }
        }
        else static if (is(ValueType!T == struct)) {
            // The value type is a struct - instantiate it
            ValueType!T newStruct;

            // ...deserialize into the new instance
            newStruct.deserializeFromJSONValue(value);

            // ...and add it to the associative array
            associativeArray[key] = newStruct;
        }
        else static if (isSomeString!(ValueType!T)) {
            associativeArray[key] = value.get!string.to!(ValueType!T);
        }
        else {
            associativeArray[key] = value.to!(ValueType!T);
        }
    }
}

pure void deserializeFromJSONValue(T)(ref T obj, in JSONValue jsonValue) if (is(T == struct) || is(T == class)) {
    enum fieldNames = FieldNameTuple!T;

    foreach(fieldName; fieldNames) {
        alias FieldType = typeof(__traits(getMember, obj, fieldName));

        if (fieldName !in jsonValue) {
            continue;
        }

        static if (is(FieldType == struct)) {
            // This field is a struct - recurse into it
            __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
        }
        else static if (is(FieldType == class)) {
            // This field is a class - recurse into it unless it is null
            if (__traits(getMember, obj, fieldName) !is null) {
                __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
            }
        }
        else static if (isSomeString!FieldType) {
            // Because all string types are stored as string in JSONValue, get it as string and convert it to the correct string type
            __traits(getMember, obj, fieldName) = jsonValue[fieldName].get!string.to!FieldType;
        }
        else static if (isArray!FieldType) {
            // Field is an array
            __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
        }
        else static if (isAssociativeArray!FieldType) {
            // Field is an associative array
            __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
        }
        else {
            __traits(getMember, obj, fieldName) = jsonValue[fieldName].to!FieldType;
        }
    }
}
