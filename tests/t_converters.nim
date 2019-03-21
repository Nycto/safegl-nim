import safegl, unittest

suite "Vector and matrix conversion":

    test "Allow implicit conversions of vectors":
        let foo: GLvectorf2 = [ 1.0, 1.0 ]
        let bar: GLvectorf3 = [ 1.0, 1.0, 1.0 ]
        let baz: GLvectorf4 = [ 1.0, 2.0, 3.0, 4.0 ]

        check baz[0] == 1.0
        check baz[1] == 2.0
        check baz[2] == 3.0
        check baz[3] == 4.0

        let foo2: GLvectorf2 = [ 1, 1 ]
        let bar2: GLvectorf3 = [ 1, 1, 1 ]
        let baz2: GLvectorf4 = [ 1, 1, 1, 1 ]

        let foo3: GLvectori2 = [ 1, 1 ]
        let bar3: GLvectori3 = [ 1, 1, 1 ]
        let baz3: GLvectori4 = [ 1, 1, 1, 1 ]

    test "Allow implicit conversion of matrixes":
        let bar: GLmatrixi3 = [ [1, 2, 3],      [4, 5, 6],      [7, 8, 9] ]
        let baz: GLmatrixi4 = [ [1, 2, 3, 4],   [4, 5, 6, 7],   [7, 8, 9, 10],  [ 11, 12, 13, 14 ] ]

        check bar[0, 0] == 1.Glint
        check bar[2, 2] == 9.Glint

