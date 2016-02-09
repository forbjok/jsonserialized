module jsonserialized.unittests;

@safe:

unittest {
    import dunit.toolkit;

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
    assertEqual(ts2.singleInt, ts.singleInt);
    assertEqual(ts2.intArray, ts.intArray);
    assertEqual(ts2.arrayOfIntArrays, ts.arrayOfIntArrays);
    assertEqual(ts2.intStringAssocArray, ts.intStringAssocArray);
    assertEqual(ts2.intIntAssocArray, ts.intIntAssocArray);
    assertEqual(ts2.singleChar, ts.singleChar);
    assertEqual(ts2.charArray, ts.charArray);
    assertEqual(ts2.singleString, ts.singleString);
    assertEqual(ts2.stringArray, ts.stringArray);
    assertEqual(ts2.arrayOfStringArrays, ts.arrayOfStringArrays);
    assertEqual(ts2.stringAssocArray, ts.stringAssocArray);
    assertEqual(ts2.stringAssocArrayOfAssocArrays, ts.stringAssocArrayOfAssocArrays);
    assertEqual(ts2.subStruct, ts.subStruct);
    assertEqual(ts2.subStruct.anotherInt, ts.subStruct.anotherInt);

    // Attempt to deserialize partial JSON
    TestStruct ts3;
    ts3.deserializeFromJSONValue(`{ "singleInt": 42, "singleString": "Don't panic." }`.toJSONValue());

    ts3.singleInt.assertEqual(42);
    ts3.singleString.assertEqual("Don't panic.");

    // Attempt to deserialize JSON containing a property that does not exist in the struct
    TestStruct ts4;
    ts4.deserializeFromJSONValue(`{ "nonexistentString": "Move along, nothing to see here." }`.toJSONValue());
}

unittest {
    import dunit.toolkit;

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
    assertEqual(tc2.singleInt, tc.singleInt);
    assertEqual(tc2.intArray, tc.intArray);
    assertEqual(tc2.arrayOfIntArrays, tc.arrayOfIntArrays);
    assertEqual(tc2.intStringAssocArray, tc.intStringAssocArray);
    assertEqual(tc2.intIntAssocArray, tc.intIntAssocArray);
    assertEqual(tc2.singleChar, tc.singleChar);
    assertEqual(tc2.charArray, tc.charArray);
    assertEqual(tc2.singleString, tc.singleString);
    assertEqual(tc2.stringArray, tc.stringArray);
    assertEqual(tc2.arrayOfStringArrays, tc.arrayOfStringArrays);
    assertEqual(tc2.stringAssocArray, tc.stringAssocArray);
    assertEqual(tc2.stringAssocArrayOfAssocArrays, tc.stringAssocArrayOfAssocArrays);
    assertEqual(tc2.subClass.anotherInt, tc.subClass.anotherInt);
}
