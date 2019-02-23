import opengl_tools, unittest, opengl

suite "Vector operations":

    test "Allow implicit conversions":
        let foo: GLvectorf2 = [ 1.0, 1.0 ]
        let bar: GLvectorf3 = [ 1.0, 1.0, 1.0 ]
        let baz: GLvectorf4 = [ 1.0, 1.0, 1.0, 1.0 ]

    test "Vector equality for GLvectorf2":
        let foo: GLvectorf2 = [ 1.0, 1.0 ]
        let bar: GLvectorf2 = [ 1.0, 1.0 ]
        let baz: GLvectorf2 = [ 1.0, 2.0 ]
        check(foo == bar)
        check(foo != baz)

    test "Vector equality for GLvectorf3":
        let foo: GLvectorf3 = [ 1.0, 1.0, 1.0 ]
        let bar: GLvectorf3 = [ 1.0, 1.0, 1.0 ]
        let baz: GLvectorf3 = [ 1.0, 1.0, 2.0 ]
        check(foo == bar)
        check(foo != baz)

    test "Vector equality for GLvectorf4":
        let foo: GLvectorf4 = [ 1.0, 1.0, 1.0, 1.0 ]
        let bar: GLvectorf4 = [ 1.0, 1.0, 1.0, 1.0 ]
        let baz: GLvectorf4 = [ 1.0, 1.0, 1.0, 2.0 ]
        check(foo == bar)
        check(foo != baz)

    test "Vector multiplication with scalar":
        let foo: GLvectorf2 = [ 1.0, 2.0 ]
        check((foo * 5) == [ 5.0, 10.0 ])
        check((5 * foo) == [ 5.0, 10.0 ])

        let bar: GLvectorf3 = [ 1.0, 2.0, 3.0 ]
        check((bar * 5) == [ 5.0, 10.0, 15.0 ])
        check((5 * bar) == [ 5.0, 10.0, 15.0 ])

        let baz: GLvectorf4 = [ 1.0, 2.0, 3.0, 4.0 ]
        check((baz * 5) == [ 5.0, 10.0, 15.0, 20.0 ])
        check((5 * baz) == [ 5.0, 10.0, 15.0, 20.0 ])

    test "Vector division by scalar":
        let foo: GLvectorf2 = [ 1.0, 2.0 ]
        check((foo / 2) == [ 0.5, 1.0 ])

        let bar: GLvectorf3 = [ 1.0, 2.0, 3.0 ]
        check((bar / 2) == [ 0.5, 1.0, 1.5 ])

        let baz: GLvectorf4 = [ 1.0, 2.0, 3.0, 4.0 ]
        check((baz / 2) == [ 0.5, 1.0, 1.5, 2.0 ])

    test "Adding vectors":
        check(GLvectorf2([ 1.0, 2.0 ]) + [ 2.0, 3.0 ] == [ 3.0, 5.0 ])
        check(GLvectorf3([ 1.0, 2.0, 3.0 ]) + [ 2.0, 3.0, 4.0 ] == [ 3.0, 5.0, 7.0 ])
        check(GLvectorf4([ 1.0, 2.0, 3.0, 4.0 ]) + [ 2.0, 3.0, 4.0, 5.0 ] == [ 3.0, 5.0, 7.0, 9.0 ])

