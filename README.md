# jsonserialized [![Build Status](https://travis-ci.org/forbjok/jsonserialized.svg?branch=master)](https://travis-ci.org/forbjok/jsonserialized)

JSON serialization library for std_data_json. Easily serialize/deserialize structs and classes to/from a JSONValue.

## How to use
```D
import jsonserialized.serialization;
import jsonserialized.deserialization;
import stdx.data.json;

struct MyStruct {
    int intField;
    string stringField;
}

MyStruct st;

st.intField = 42;
st.stringField = "Don't panic.";

// Serialize the struct to JSON
auto jsonValue = st.serializeToJSONValue();

// Create a new empty struct
MyStruct st2;

// Deserialize the JSONValue into it
st2.deserializeFromJSONValue(jsonValue);
```
