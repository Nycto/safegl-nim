import opengl

converter toVector2f*(ary: array[0..1, SomeFloat]): GLvectorf2 =
    ## Convert an array of floats to a GL vector
    [ ary[0].GLfloat, ary[1].GLfloat ]

converter toVector3f*(ary: array[0..2, SomeFloat]): GLvectorf3 =
    ## Convert an array of floats to a GL vector
    [ ary[0].GLfloat, ary[1].GLfloat, ary[2].GLfloat ]

converter toVector4f*(ary: array[0..3, SomeFloat]): GLvectorf4 =
    ## Convert an array of floats to a GL vector
    [ ary[0].GLfloat, ary[1].GLfloat, ary[2].GLfloat, ary[3].GLfloat ]

template `*`*(vector: GLvectorf2, num: SomeNumber): GLvectorf2 =
    ## Allow multiplication of vectors
    [ vector[0].GLfloat * num.GLfloat, vector[1].GLfloat * num.GLfloat ]

template `*`*(vector: GLvectorf3, num: SomeNumber): GLvectorf3 =
    ## Allow multiplication of vectors
    [ vector[0].GLfloat * num.GLfloat, vector[1].GLfloat * num.GLfloat, vector[2].GLfloat * num.GLfloat ]

template `*`*(vector: GLvectorf4, num: SomeNumber): GLvectorf4 =
    ## Allow multiplication of vectors
    [
        vector[0].GLfloat * num.GLfloat,
        vector[1].GLfloat * num.GLfloat,
        vector[2].GLfloat * num.GLfloat,
        vector[3].GLfloat * num.GLfloat ]

template `*`*(num: SomeNumber, vector: GLvectorf2|GLvectorf3|GLvectorf4): auto = vector * num

proc `/`*(vector: GLvectorf2, num: SomeNumber): GLvectorf2 =
    ## Allow division of vectors by a number
    [ vector[0].GLfloat / num.GLfloat, vector[1].GLfloat / num.GLfloat ]

proc `/`*(vector: GLvectorf3, num: SomeNumber): GLvectorf3 =
    ## Allow division of vectors by a number
    [ vector[0].GLfloat / num.GLfloat, vector[1].GLfloat / num.GLfloat, vector[2].GLfloat / num.GLfloat ]

proc `/`*(vector: GLvectorf4, num: SomeNumber): GLvectorf4 =
    ## Allow division of vectors by a number
    [
        vector[0].GLfloat / num.GLfloat,
        vector[1].GLfloat / num.GLfloat,
        vector[2].GLfloat / num.GLfloat,
        vector[3].GLfloat / num.GLfloat ]

proc `+`*(left, right: GLvectorf2): GLvectorf2 =
    ## Allow addition of vectors
    [ left[0] + right[0], left[1] + right[1] ]

proc `+`*(left, right: GLvectorf3): GLvectorf3 =
    ## Allow addition of vectors
    [ left[0] + right[0], left[1] + right[1], left[2] + right[2] ]

proc `+`*(left, right: GLvectorf4): GLvectorf4 =
    ## Allow addition of vectors
    [ left[0] + right[0], left[1] + right[1], left[2] + right[2], left[3] + right[3] ]

