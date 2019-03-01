import enums, opengl, sequtils

type
    OglVertexAttrib* = object ## An individual attribute for a vertex
        count: GLint ## The number of values being passed
        dataType: OglVertexType ## The data type

    OglVertexShape*[T] = object ## The shape of the arguments for a vertex
        attribs: seq[OglVertexAttrib]

    OglVertexArrayId* = distinct GLuint

    OglVertexBufferId* = distinct GLuint

    OglVertexArray* = object
        id: OglVertexArrayId
        buffers: seq[OglVertexBufferId]
        vertexCount: int

proc size(dataType: OglVertexType): int =
    case dataType
    of OglVertexType.ByteType: sizeof(GLbyte)
    of OglVertexType.UnsignedByteType: sizeof(GLubyte)
    of OglVertexType.ShortType: sizeof(GLshort)
    of OglVertexType.UnsignedShortType: sizeof(GLushort)
    of OglVertexType.IntType: sizeof(GLint)
    of OglVertexType.FloatType: sizeof(GLfloat)
    of OglVertexType.DoubleType: sizeof(GLdouble)

proc defineVertexShape*[T](attribs: varargs[OglVertexAttrib]): OglVertexShape[T] =
    ## Defines the shape of the data being passed to the shaders
    result.attribs.add(attribs)

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

proc attrib*(count: static[int], dataType: static[OglVertexType]): OglVertexAttrib =
    ## Defines the shape of the data being passed to the shaders
    result.count = count.GLint
    result.dataType = dataType

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

