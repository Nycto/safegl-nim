import safegl, unittest

suite "Vector operations":

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

    test "Perform matrix multiplication on matrixes of different sizes":
        let matrix1: Matrix[2, 3, int] = [
            [1, 2, 3],
            [4, 5, 6]
        ]

        let matrix2: Matrix[3, 5, int] = [
            [7,   8,  9, 10, 11],
            [12, 13, 14, 15, 16],
            [17, 18, 19, 20, 21]
        ]

        check matrix1 * matrix2 == [
            [ 82,   88,  94, 100, 106 ],
            [ 190, 205, 220, 235, 250 ]
        ]

    test "Perform matrix multiplication on native opengl types":
        let matrix1: GLmatrixf3 = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]

        let matrix2: GLmatrixf3 = [
            [10, 11, 12],
            [13, 14, 15],
            [16, 17, 18]
        ]

        check matrix1 * matrix2 == [
            [ 84,  90,  96  ],
            [ 201, 216, 231 ],
            [ 318, 342, 366 ]
        ]

    test "Perform matrix multiplication on vectors":
        let vector: Vector[4, int] = [1, 2, 3, 4]

        let matrix: Matrix[4, 2, int] = [
            [ 5,  6],
            [ 7,  8],
            [ 9, 10],
            [11, 12]
        ]

        check vector * matrix == [ 90, 100 ]

    test "Perform matrix multiplication on native opengl types":
        let vector: GLvectorf3 = [1, 2, 3]

        let matrix: GLmatrixf3 = [
            [ 4,  5,  6],
            [ 7,  8,  9],
            [10, 11, 12]
        ]

        check vector * matrix == [ 48, 54, 60 ]


