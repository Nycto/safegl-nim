import safegl, unittest

suite "Vector operations":

    test "Allow implicit conversions":
        let foo: GLvectorf2 = [ 1.0, 1.0 ]
        let bar: GLvectorf3 = [ 1.0, 1.0, 1.0 ]
        let baz: GLvectorf4 = [ 1.0, 1.0, 1.0, 1.0 ]

