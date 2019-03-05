import ../enums, opengl, macros, strutils

proc size*(dataType: OglType): int =
    ## Returns the size of an attribute data type
    case dataType
    of OglType.ByteType: sizeof(GLbyte)
    of OglType.UnsignedByteType: sizeof(GLubyte)
    of OglType.ShortType: sizeof(GLshort)
    of OglType.UnsignedShortType: sizeof(GLushort)
    of OglType.IntType: sizeof(GLint)
    of OglType.FloatType: sizeof(GLfloat)
    of OglType.DoubleType: sizeof(GLdouble)

proc asType*(typename: NimNode): OglType =
    ## Converts a type declaration to an OglType
    case typename.strVal.toLowerAscii
    of "glbyte": OglType.ByteType
    of "glubyte": OglType.UnsignedByteType
    of "glshort": OglType.ShortType
    of "glushort": OglType.UnsignedShortType
    of "glint": OglType.IntType
    of "glfloat": OglType.FloatType
    of "gldouble": OglType.DoubleType
    else:
        error(
            "Could not determine vertex attribute type for: " & typename.strVal &
            " (Make sure you're using the GL types, for example GLint or GLfloat)",
            typename
        )
        low(OglType)
