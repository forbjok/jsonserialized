module jsonserialized.deserialization;

import std.conv;
import stdx.data.json;
import std.traits;

@safe:

pure void deserializeFromJSONValue(T)(ref T array, JSONValue jsonValue) if (isArray!T) {
    // Iterate each item in the array JSONValue and add them to values, converting them to the actual type
    foreach(jvItem; jsonValue.get!(JSONValue[])) {
        static if (isSomeString!(ForeachType!T)) {
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

pure void deserializeFromJSONValue(T)(ref T associativeArray, JSONValue jsonValue) if (isAssociativeArray!T) {
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
        else static if (isSomeString!(ValueType!T)) {
            associativeArray[key] = value.get!string.to!(ValueType!T);
        }
        else {
            associativeArray[key] = value.to!(ValueType!T);
        }
    }
}

pure void deserializeFromJSONValue(T)(ref T obj, JSONValue jsonValue) if (is(T == struct)) {
    foreach(memberName; __traits(allMembers, T)) {
        alias MemberType = typeof(__traits(getMember, obj, memberName));

        if (memberName !in jsonValue) {
            continue;
        }

        static if (is(MemberType == struct)) {
            // This member is a struct - recurse into it
            __traits(getMember, obj, memberName).deserializeFromJSONValue(jsonValue[memberName]);
        }
        else static if (isSomeString!MemberType) {
            // Because all string types are stored as string in JSONValue, get it as string and convert it to the correct string type
            __traits(getMember, obj, memberName) = jsonValue[memberName].get!string.to!MemberType;
        }
        else static if (isArray!MemberType) {
            // Member is an array
            __traits(getMember, obj, memberName).deserializeFromJSONValue(jsonValue[memberName]);
        }
        else static if (isAssociativeArray!MemberType) {
            // Member is an associative array
            __traits(getMember, obj, memberName).deserializeFromJSONValue(jsonValue[memberName]);
        }
        else {
            __traits(getMember, obj, memberName) = jsonValue[memberName].to!MemberType;
        }
    }
}
