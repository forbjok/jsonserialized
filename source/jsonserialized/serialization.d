module jsonserialized.serialization;

import std.conv;
import stdx.data.json;
import std.traits;

@safe:

pure JSONValue serializeToJSONValue(T)(in ref T array) if (isArray!T) {
    JSONValue[] values;

    // Iterate each item in the array and add them to the array of JSON values
    foreach(item; array) {
        static if (isSomeString!(ForeachType!T)) {
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

        static if (isAssociativeArray!(ValueType!T)) {
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

pure JSONValue serializeToJSONValue(T)(in ref T obj) if (is(T == struct)) {
    JSONValue[string] jsonValues;

    foreach(memberName; __traits(allMembers, T)) {
        auto member = __traits(getMember, obj, memberName);
        alias MemberType = typeof(member);

        static if (is(MemberType == struct)) {
            // This member is a struct - recurse into it
            jsonValues[memberName] = member.serializeToJSONValue();
        }
        else static if (isSomeString!MemberType) {
            // Because JSONValue only seems to work with string strings (and not char[], etc), convert all string types to string
            jsonValues[memberName] = JSONValue(member.to!string);
        }
        else static if (isArray!MemberType) {
            // Member is an array
            jsonValues[memberName] = member.serializeToJSONValue();
        }
        else static if (isAssociativeArray!MemberType) {
            // Member is an associative array
            jsonValues[memberName] = member.serializeToJSONValue();
        }
        else {
            jsonValues[memberName] = JSONValue(member);
        }
    }

    return JSONValue(jsonValues);
}
