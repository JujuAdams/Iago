// Feather disable all

show_debug_message("-----------------------------------------------------------------------------");
show_debug_message(object_get_name(object_index));
show_debug_message("-----------------------------------------------------------------------------");

input = {
    "productId": 1,
    "productName": "A green door",
    "price": 12.50,
    "tags": ["home", "green"],
};

//Missing a property
brokenInput0 = {
    "productName": "A green door",
    "price": 12.50,
    "tags": ["home", "green"],
};

//Non-numeric property
brokenInput1 = {
    "productId": undefined,
    "productName": "A green door",
    "price": 12.50,
    "tags": ["home", "green"],
};

//Non-string property
brokenInput2 = {
    "productId": 1,
    "productName": undefined,
    "price": 12.50,
    "tags": ["home", "green"],
};

//Non-array property
brokenInput2 = {
    "productId": 1,
    "productName": undefined,
    "price": 12.50,
    "tags": undefined,
};

//Non-compliant array element
brokenInput3 = {
    "productId": 1,
    "productName": undefined,
    "price": 12.50,
    "tags": ["home", 42],
};

schema = IagoGenerate("test", input);
show_debug_message(json_stringify(schema, true));

show_debug_message($"Expect 1: {IagoTest(schema, input       )}");
show_debug_message($"Expect 0: {IagoTest(schema, brokenInput0)}");
show_debug_message($"Expect 0: {IagoTest(schema, brokenInput1)}");
show_debug_message($"Expect 0: {IagoTest(schema, brokenInput2)}");
show_debug_message($"Expect 0: {IagoTest(schema, brokenInput3)}");

show_debug_message("-----------------------------------------------------------------------------");