// Feather disable all

show_debug_message("-----------------------------------------------------------------------------");
show_debug_message(object_get_name(object_index));
show_debug_message("-----------------------------------------------------------------------------");

funcConstructorA = function() constructor
{
    propString = "string";
    propNumber = 42;
    propBool   = true;
    propNull   = undefined;
}

funcConstructorB = function(_constructor) constructor
{
    propArray = [new _constructor(), new _constructor()];
}

inputA = new funcConstructorA();
inputB = new funcConstructorB(funcConstructorA);

brokenInputB0 = {
    "propArray":[
        {
            "propBool":   true,
            "propString": "string",
            //Missing property
            "propNumber": 42.0
        },
        {
            "propBool":   true,
            "propNull":   undefined,
            "propString": "string",
            "propNumber": 42.0
        },
    ],
};

workingInputB0 = {
    "propArray":[
        {
            "propBool":   true,
            "propNull":   undefined,
            "propString": "string",
            "propNumber": 42.0
        },
        //Missing struct of `funcConstructorA()`
    ],
};

workingInputB1 = {
    "propArray":[
        {
            "propBool":   true,
            "propNull":   undefined,
            "propString": "string",
            "propNumber": 42.0
        },
        {
            "propBool":   true,
            "propNull":   undefined,
            "propString": "string",
            "propNumber": 42.0
        },
        //Extra struct of `funcConstructorA()`
        {
            "propBool":   true,
            "propNull":   undefined,
            "propString": "string",
            "propNumber": 42.0
        },
    ],
};

show_debug_message(json_stringify(inputA, true));
show_debug_message(json_stringify(inputB, true));

schemaA = IagoGenerate("funcConstructorA", inputA);
show_debug_message(json_stringify(schemaA, true));
IagoAddID(schemaA);
IagoAddInstanceOf(schemaA, inputA);

schemaB = IagoGenerate("funcConstructorB", inputB);
show_debug_message(json_stringify(schemaB, true));
IagoAddID(schemaB);
IagoAddInstanceOf(schemaB, inputB);

show_debug_message($"Expect 1: {IagoTest(schemaA, inputA)}");
show_debug_message($"Expect 1: {IagoTest(schemaB, inputB)}");
show_debug_message($"Expect 0: {IagoTest(schemaB, inputA)}");
show_debug_message($"Expect 0: {IagoTest(schemaA, inputB)}");
show_debug_message($"Expect 0: {IagoTest(schemaB, brokenInputB0)}");
show_debug_message($"Expect 1: {IagoTest(schemaB, workingInputB0)}");
show_debug_message($"Expect 1: {IagoTest(schemaB, workingInputB1)}");

show_debug_message("-----------------------------------------------------------------------------");