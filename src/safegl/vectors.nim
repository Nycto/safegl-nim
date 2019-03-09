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

