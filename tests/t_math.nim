import safegl, unittest

suite "Vector and Matrix math operations":

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

    test "Set a matrix back to identity":
        var matrix = [
            [ 4,  5,  6],
            [ 7,  8,  9],
            [10, 11, 12]
        ]

        matrix.identity()

        check matrix == [
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
        ]

    test "Create an identity matrix":
        let matrix = newIdentity[4, int]()
        check matrix == [
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1],
        ]


