1)  The 'validates' method iterates over each of the validations and passes along the parsed information to 'validates_with'

2)  Validates_array should mimic the 'validates' method in this regard, but call 'validates_array_values_with' (which will do what 'validates_with' does, but by iterating over each value)

TODO:  Look up/copy 'def validates_with' to understand that function and duplicate its functionality.