import enums, opengl, sequtils, macros, strutils, private/reflection

type
    OglVertexAttrib* = object ## An individual attribute for a vertex
        name: string ## The name of this field
        count: GLint ## The number of values being passed
        dataType: OglType ## The data type

    OglVertexShape*[T] = object ## The shape of the arguments for a vertex
        attribs: seq[OglVertexAttrib]

    OglVertexArrayId = distinct GLuint

    OglVertexBufferId = distinct GLuint

    OglVertexArray* = object
        id: OglVertexArrayId
        buffers: seq[OglVertexBufferId]
        vertexCount: int

proc `$`(attrib: OglVertexAttrib): string =
    ## Convert an attrib to a string
    result = attrib.name & ": " & $attrib.dataType & " * " & $attrib.count

proc `$`*[T](shape: OglVertexShape[T]): string =
    ## Convert a shape to a string
    result = "VertexShape(" & shape.attribs.mapIt($it).join(", ") & ")"

proc size(dataType: OglType): int =
    ## Returns the size of an attribute data type
    case dataType
    of OglType.ByteType: sizeof(GLbyte)
    of OglType.UnsignedByteType: sizeof(GLubyte)
    of OglType.ShortType: sizeof(GLshort)
    of OglType.UnsignedShortType: sizeof(GLushort)
    of OglType.IntType: sizeof(GLint)
    of OglType.FloatType: sizeof(GLfloat)
    of OglType.DoubleType: sizeof(GLdouble)

proc asAttribType(typename: NimNode): OglType =
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

proc getAttribInfo(typename: NimNode): tuple[count: GLint, dataType: OglType] =
    ## Given a type name, returns data for constructing an OglVertexAttrib

    # This will de-obfuscate the GL type aliases back to arrays
    let dealiased = typename.getTypeImpl

    # If we are dealing with an array:
    if dealiased.kind == nnkBracketExpr:
        expectKind dealiased[0], nnkSym
        assert(dealiased[0].strVal == "array")

        # Recursively determine the type of values in this array
        let nested = dealiased[2].getAttribInfo
        result.count = GLint(dealiased[1].getRangeSize) * nested.count
        result.dataType = nested.dataType

    else:
        result.count = 1
        result.dataType = typename.asAttribType

macro getTypeShape(struct: typed): untyped =
    ## Constructs a sequence of OglVertexAttrib shapes based on a type name

    var attribs = nnkBracket.newTree()

    for field, typeinfo in objFields(struct):
        let (count, dataType) = getAttribInfo(typeinfo)

        attribs.add(nnkObjConstr.newTree(
            ident("OglVertexAttrib"),
            newColonExpr(ident("name"), newLit(field)),
            newColonExpr(ident("count"), newLit(count)),
            newColonExpr(ident("dataType"), newDotExpr(ident("OglType"), ident($dataType))),
        ))

    result = prefix(attribs, "@")

proc defineVertexShape*(shape: typedesc): OglVertexShape[shape] =
    ## Defines the shape of the data being passed to the shaders
    result.attribs = getTypeShape(shape)

proc send[T](shape: OglVertexShape[T]) =
    ## Sends a vertex shape over to opengl
    var offset = 0
    for i, attrib in shape.attribs:
        glVertexAttribPointer(
            i.GLuint,
            attrib.count,
            attrib.dataType.glEnum,
            GL_FALSE,
            sizeof(T).Glsizei,
            cast[Glvoid](offset))
        glEnableVertexAttribArray(i.GLuint)

        offset += attrib.count * attrib.dataType.size

proc genVertexArray(): OglVertexArrayId =
    ## Creates a vertex array
    var vao: GLuint
    glGenVertexArrays(1, addr vao)
    result = vao.OglVertexArrayId

proc bindArray(id: OglVertexArrayId): OglVertexArrayId =
    ## Binds a vertex array
    glBindVertexArray(id.GLuint)
    result = id

proc genVertexBuffer(): OglVertexBufferId =
    ## Creates a vertex array
    var vbo: GLuint
    glGenBuffers(1, addr vbo)
    result = vbo.OglVertexBufferId

proc bindBuffer(id: OglVertexBufferId): OglVertexBufferId =
    ## Binds a vertex buffer
    glBindBuffer(GL_ARRAY_BUFFER, id.GLuint)
    result = id

proc newVertexArray*[T](shape: OglVertexShape[T], vertices: openarray[T]): OglVertexArray =
    ## Creates a vertex array instance
    result.id = genVertexArray().bindArray()
    result.buffers.add(genVertexBuffer().bindBuffer())
    result.vertexCount = vertices.len

    glBufferData(GL_ARRAY_BUFFER, sizeof(T) * vertices.len, unsafeAddr(vertices[0]), GL_STATIC_DRAW)

    shape.send

    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindVertexArray(0)

template draw*(self: OglVertexArray) =
    ## Draws a vertex array
    glBindVertexArray(self.id.GLuint)
    glDrawArrays(GL_TRIANGLES, 0, self.vertexCount.GLsizei)
    glBindVertexArray(0)
