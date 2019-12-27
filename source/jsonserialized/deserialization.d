module jsonserialized.deserialization;

import std.conv;
import stdx.data.json;
import std.traits;

/// Deserialize the contents of a JSONValue into the specified array.
pure void deserializeFromJSONValue(T)(ref T array, in JSONValue jsonValue) if (isArray!T) {
    alias ElementType = ForeachType!T;

    // Iterate each item in the array JSONValue and add them to values, converting them to the actual type
    foreach(jvItem; jsonValue.get!(JSONValue[])) {
        static if (is(ElementType == struct)) {
            // This item is a struct - instantiate it
            ElementType newStruct;

            // ...deserialize into the new instance
            newStruct.deserializeFromJSONValue(jvItem);

            // ...and add it to the array
            array ~= newStruct;
        }
        else static if (is(ElementType == class)) {
            // The item type is class - create a new instance
            auto newClass = new ElementType();

            // ...deserialize into the new instance
            newClass.deserializeFromJSONValue(jvItem);

            // ...and add it to the array
            array ~= newClass;
        }
        else static if (isSomeString!ElementType) {
            array ~= jvItem.get!string.to!ElementType;
        }
        else static if (isArray!ElementType) {
            // An array of arrays. Recursion time!
            ElementType subArray;

            subArray.deserializeFromJSONValue(jvItem);
            array ~= subArray;
        }
        else {
            array ~= jvItem.to!ElementType;
        }
    }
}

/// Deserialize the contents of a JSONValue into the specified associative array.
pure void deserializeFromJSONValue(T)(ref T associativeArray, in JSONValue jsonValue) if (isAssociativeArray!T) {
    alias VType = ValueType!T;

    // Iterate each item in the JSON object
    foreach(stringKey, value; jsonValue.get!(JSONValue[string])) {
        auto key = stringKey.to!(KeyType!T);

        static if (isAssociativeArray!VType) {
            /* The associative array's value type is another associative array type.
               It's recursion time. */

            if (key in associativeArray) {
                associativeArray[key].deserializeFromJSONValue(value);
            }
            else {
                VType subAssocArray;

                subAssocArray.deserializeFromJSONValue(value);
                associativeArray[key] = subAssocArray;
            }
        }
        else static if (is(VType == struct)) {
            // The value type is a struct - instantiate it
            VType newStruct;

            // ...deserialize into the new instance
            newStruct.deserializeFromJSONValue(value);

            // ...and add it to the associative array
            associativeArray[key] = newStruct;
        }
        else static if (is(VType == class)) {
            // The value type is class - create a new instance
            auto newClass = new VType();

            // ...deserialize into the new instance
            newClass.deserializeFromJSONValue(value);

            // ...and add it to the associative array
            associativeArray[key] = newClass;
        }
        else static if (isSomeString!VType) {
            string v;

            if (value.hasType!string)
                v = value.get!string;
            else if (value.hasType!long)
                v = value.get!long.to!string;

            associativeArray[key] = v.to!VType;
        }
        else {
            associativeArray[key] = value.to!VType;
        }
    }
}

/// Deserialize the contents of a JSONValue into the specified struct or class.
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
            // If the JSONValue does not contain a string, don't try to deserialize
            if (!jsonValue[fieldName].hasType!string)
                continue;

            // Because all string types are stored as string in JSONValue, get it as string and convert it to the correct string type
            __traits(getMember, obj, fieldName) = jsonValue[fieldName].get!string.to!FieldType;
        }
        else static if (isArray!FieldType) {
            // If the JSONValue does not contain an array, don't try to deserialize
            if (!jsonValue[fieldName].hasType!(JSONValue[]))
                continue;

            // Field is an array
            __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
        }
        else static if (isAssociativeArray!FieldType) {
            // Field is an associative array
            __traits(getMember, obj, fieldName).deserializeFromJSONValue(jsonValue[fieldName]);
        }
        else static if (isIntegral!FieldType) {
            // If the JSONValue type does not contain a long, don't try to deserialize
            if (!jsonValue[fieldName].hasType!long)
                continue;

            __traits(getMember, obj, fieldName) = jsonValue[fieldName].to!FieldType;
        }
        else {
            __traits(getMember, obj, fieldName) = jsonValue[fieldName].to!FieldType;
        }
    }
}

/// Deserialize the contents of a JSONValue into a struct of type T, returning the newly created struct.
pure T deserializeFromJSONValue(T)(in JSONValue jsonValue) if (is(T == struct)) {
    T obj;

    obj.deserializeFromJSONValue(jsonValue);
    return obj;
}
