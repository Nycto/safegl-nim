import opengl

export GLmatrixi3, GLint, GLbyte, GLubyte
export GLvectorf2, GLvectorf3, GLvectorf4, GLvectori2, GLvectori3, GLvectori4
export GLmatrixi3, GLmatrixf3, GLmatrixd3, GLmatrixub4, GLmatrixi4, GLmatrixf4, GLmatrixd4

type
    Matrix*[Rows, Cols: static[int], T: SomeNumber] = array[Rows, array[Cols, T]] ## Matrix alias type
    Vector*[Cols: static[int], T: SomeNumber] = array[Cols, T] ## Vector alias type

proc `[]`*[Rows, Cols: static[int], T](self: Matrix[Rows, Cols, T], x, y: int): T {. inline .} =
    ## Single bracket access to an x/y coordinate
    result = self[x][y]

proc `*`*[N, M, P: static[int], T: SomeNumber](a: Matrix[N, M, T], b: Matrix[M, P, T]): Matrix[N, P, T] =
    ## Multiplies two matrices

    # TODO: optimize me
    for i in 0..(N - 1):
        for j in 0..(P - 1):
            var sum: T = 0
            for k in 0..(M - 1):
                sum = sum + a[i][k] * b[k][j]
            result[i][j] = sum

proc `*`*[N, M: static[int], T: SomeNumber](a: Vector[N, T], b: Matrix[N, M, T]): Vector[M, T] =
    ## Multiplies a vector by a matrix

    # TODO: optimize me
    for i in 0..(M - 1):
        var sum: T = 0
        for k in 0..(N - 1):
            sum = sum + a[k] * b[k][i]
        result[i] = sum

proc identity*[N: static[int]; T: SomeNumber](matrix: var Matrix[N, N, T]) =
    ## Sets a matrix back to an identity matrix
    matrix.addr.zeroMem(sizeOf(Matrix[N, N, T]))
    for i in 0..(N - 1):
        matrix[i][i] = T(1)

proc newIdentity*[N: static[int]; T: SomeNumber](): Matrix[N, N, T] =
    ## Instantiates a new identity matrix
    result.identity()




