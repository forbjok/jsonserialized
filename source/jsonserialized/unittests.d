module jsonserialized.unittests;

@safe:

unittest {
    import jsonserialized.serialization;
    import jsonserialized.deserialization;
    import stdx.data.json;

    struct TestSubStruct {
        int anotherInt;
    }

    struct TestStruct {
        int singleInt;
        int[] intArray;
        int[][] arrayOfIntArrays;
        int[string] intStringAssocArray;
        int[int] intIntAssocArray;
        char singleChar;
        char[] charArray;
        string singleString;
        string[] stringArray;
        string[][] arrayOfStringArrays;
        string[string] stringAssocArray;
        string[string][string] stringAssocArrayOfAssocArrays;

        TestSubStruct subStruct;
    }

    // Create test struct and set it up with some test values
    TestStruct ts;
    with (ts) {
        singleInt = 1234;
        intArray = [1, 2, 3, 4];
        arrayOfIntArrays = [[1, 2], [3, 4]];
        intStringAssocArray = ["one": 1, "two": 2, "three": 3];
        intIntAssocArray = [1: 3, 2: 1, 3: 2];
        singleChar = 'A';
        charArray = ['A', 'B', 'C', 'D'];
        singleString = "just a string";
        stringArray = ["a", "few", "strings"];
        arrayOfStringArrays = [["a", "b"], ["c", "d"]];
        stringAssocArray = ["a": "A", "b": "B", "c": "C"];
        stringAssocArrayOfAssocArrays = ["a": ["a": "A", "b": "B"], "b": ["c": "C", "d": "D"]];
        subStruct.anotherInt = 42;
    }

    // Serialize the struct to JSON
    auto jv = ts.serializeToJSONValue();

    // Create a new empty struct
    TestStruct ts2;

    // Deserialize the JSONValue into it
    ts2.deserializeFromJSONValue(jv);

    // Assert that both structs are identical
    assert(ts2.singleInt == ts.singleInt);
    assert(ts2.intArray == ts.intArray);
    assert(ts2.arrayOfIntArrays == ts.arrayOfIntArrays);
    assert(ts2.intStringAssocArray == ts.intStringAssocArray);
    assert(ts2.intIntAssocArray == ts.intIntAssocArray);
    assert(ts2.singleChar == ts.singleChar);
    assert(ts2.charArray == ts.charArray);
    assert(ts2.singleString == ts.singleString);
    assert(ts2.stringArray == ts.stringArray);
    assert(ts2.arrayOfStringArrays == ts.arrayOfStringArrays);
    assert(ts2.stringAssocArray == ts.stringAssocArray);
    assert(ts2.stringAssocArrayOfAssocArrays == ts.stringAssocArrayOfAssocArrays);
    assert(ts2.subStruct == ts.subStruct);
    assert(ts2.subStruct.anotherInt == ts.subStruct.anotherInt);

    // Attempt to deserialize partial JSON
    TestStruct ts3;
    ts3.deserializeFromJSONValue(`{ "singleInt": 42, "singleString": "Don't panic." }`.toJSONValue());

    assert(ts3.singleInt == 42);
    assert(ts3.singleString == "Don't panic.");

    // Attempt to deserialize JSON containing a property that does not exist in the struct
    TestStruct ts4;
    ts4.deserializeFromJSONValue(`{ "nonexistentString": "Move along, nothing to see here." }`.toJSONValue());
}

unittest {
    import jsonserialized.serialization;
    import jsonserialized.deserialization;
    import stdx.data.json;

    class TestSubClass {
        int anotherInt;
    }

    class TestClass {
        int singleInt;
        int[] intArray;
        int[][] arrayOfIntArrays;
        int[string] intStringAssocArray;
        int[int] intIntAssocArray;
        char singleChar;
        char[] charArray;
        string singleString;
        string[] stringArray;
        string[][] arrayOfStringArrays;
        string[string] stringAssocArray;
        string[string][string] stringAssocArrayOfAssocArrays;

        auto subClass = new TestSubClass();
    }

    // Create test struct and set it up with some test values
    auto tc = new TestClass();
    with (tc) {
        singleInt = 1234;
        intArray = [1, 2, 3, 4];
        arrayOfIntArrays = [[1, 2], [3, 4]];
        intStringAssocArray = ["one": 1, "two": 2, "three": 3];
        intIntAssocArray = [1: 3, 2: 1, 3: 2];
        singleChar = 'A';
        charArray = ['A', 'B', 'C', 'D'];
        singleString = "just a string";
        stringArray = ["a", "few", "strings"];
        arrayOfStringArrays = [["a", "b"], ["c", "d"]];
        stringAssocArray = ["a": "A", "b": "B", "c": "C"];
        stringAssocArrayOfAssocArrays = ["a": ["a": "A", "b": "B"], "b": ["c": "C", "d": "D"]];
        subClass.anotherInt = 42;
    }

    // Serialize the struct to JSON
    auto jv = tc.serializeToJSONValue();

    // Create a new empty struct
    auto tc2 = new TestClass();

    // Deserialize the JSONValue into it
    tc2.deserializeFromJSONValue(jv);

    // Assert that both structs are identical
    assert(tc2.singleInt == tc.singleInt);
    assert(tc2.intArray == tc.intArray);
    assert(tc2.arrayOfIntArrays == tc.arrayOfIntArrays);
    assert(tc2.intStringAssocArray == tc.intStringAssocArray);
    assert(tc2.intIntAssocArray == tc.intIntAssocArray);
    assert(tc2.singleChar == tc.singleChar);
    assert(tc2.charArray == tc.charArray);
    assert(tc2.singleString == tc.singleString);
    assert(tc2.stringArray == tc.stringArray);
    assert(tc2.arrayOfStringArrays == tc.arrayOfStringArrays);
    assert(tc2.stringAssocArray == tc.stringAssocArray);
    assert(tc2.stringAssocArrayOfAssocArrays == tc.stringAssocArrayOfAssocArrays);
    assert(tc2.subClass.anotherInt == tc.subClass.anotherInt);
}
