import math, opengl

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

