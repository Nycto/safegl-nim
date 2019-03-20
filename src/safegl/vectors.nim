import opengl, macros

type GLvectorb2* = array[2, GLbyte]

export GLmatrixi3, GLint, GLbyte, GLubyte
export GLvectorf2, GLvectorf3, GLvectorf4, GLvectori2, GLvectori3, GLvectori4
export GLmatrixi3, GLmatrixf3, GLmatrixd3, GLmatrixub4, GLmatrixi4, GLmatrixf4, GLmatrixd4

type
    Matrix*[Rows, Cols: static[int], T: SomeNumber] = array[Rows, array[Cols, T]] ## Matrix alias type
    Vector*[Cols: static[int], T: SomeNumber] = array[Cols, T] ## Vector alias type

proc `[]`*[Rows, Cols: static[int], T](self: Matrix[Rows, Cols, T], x, y: int): T {. inline .} =
    ## Single bracket access to an x/y coordinate
    result = self[x][y]

template convertVector(source: typed, cols: int, assign: untyped, asType: typedesc): untyped =
    ## Converts elements in the given vector to a vector of a new type
    for i in 0..cols - 1:
        assign[i] = asType(source[i])

converter toGlintVector*[Cols: static[int]](source: Vector[Cols, SomeInteger]): Vector[Cols, GLint] {. inline .} =
    ## Converts a matrix of ints to a matrix of GLints
    convertVector(source, Cols, result, GLint)

converter toGlfloatVector*[Cols: static[int]](source: Vector[Cols, SomeNumber]): Vector[Cols, GLfloat] {. inline .} =
    ## Converts a matrix of ints to a matrix of GLfloats
    convertVector(source, Cols, result, GLfloat)

template convertMatrix(source: typed, rows, cols: int, asType: typedesc): untyped =
    ## Converts between two matrix types
    for y in 0..rows - 1:
        let row = source[y]
        convertVector(row, Cols, result[y], asType)

converter toGlintMatrix*[Rows, Cols: static[int]](
    source: Matrix[Rows, Cols, SomeInteger]
): Matrix[Rows, Cols, GLint] {. inline .} =
    ## Converts a matrix of ints to a matrix of GLints
    convertMatrix(source, Rows, Cols, GLint)

converter toGlfloatMatrix*[Rows, Cols: static[int]](
    source: Matrix[Rows, Cols, SomeNumber]
): Matrix[Rows, Cols, GLfloat] {. inline .} =
    ## Converts a matrix of ints to a matrix of GLfloats
    convertMatrix(source, Rows, Cols, GLfloat)

proc `*`*[N, M, P: static[int], T: SomeNumber](a: Matrix[N, M, T], b: Matrix[M, P, T]): Matrix[N, P, T] =
    ## Multiplies two matrices

    # TODO: optimize me
    for i in 0..(N - 1):
        for j in 0..(P - 1):
            var sum: T = 0
            for k in 0..(M - 1):
                sum = sum + a[i][k] * b[k][j]
            result[i][j] = sum


