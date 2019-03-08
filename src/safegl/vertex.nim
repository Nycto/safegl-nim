import enums, opengl, sequtils, macros, strutils, private/reflection, private/types

type
    OglVertexAttrib* = object ## An individual attribute for a vertex
        name: string ## The name of this field
        count: GLint ## The number of values being passed
        dataType: OglType ## The data type

    OglVertexShape*[T] = object ## The shape of the arguments for a vertex
        attribs: seq[OglVertexAttrib]

    OglVertexArrayId = distinct GLuint

    OglVertexBufferId = distinct GLuint

    OglVertexArray*[T] = object
        id: OglVertexArrayId
        buffers: seq[OglVertexBufferId]
        vertexCount: int

proc `$`(attrib: OglVertexAttrib): string =
    ## Convert an attrib to a string
    result = attrib.name & ": " & $attrib.dataType & " * " & $attrib.count

proc `$`*[T](shape: OglVertexShape[T]): string =
    ## Convert a shape to a string
    result = "VertexShape(" & shape.attribs.mapIt($it).join(", ") & ")"

macro getTypeShape(struct: typed): untyped =
    ## Constructs a sequence of OglVertexAttrib shapes based on a type name

    var attribs = nnkBracket.newTree()

    for field in fields(struct):
        let struct = field.structure
        attribs.add(nnkObjConstr.newTree(
            ident("OglVertexAttrib"),
            newColonExpr(ident("name"), newLit(field.name)),
            newColonExpr(ident("count"), newLit(struct.totalCount.GLint)),
            newColonExpr(ident("dataType"), newDotExpr(ident("OglType"), ident($struct.coreType))),
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

proc newVertexArray*[T](shape: OglVertexShape[T], vertices: openarray[T]): OglVertexArray[T] =
    ## Creates a vertex array instance
    result.id = genVertexArray().bindArray()
    result.buffers.add(genVertexBuffer().bindBuffer())
    result.vertexCount = vertices.len

    glBufferData(GL_ARRAY_BUFFER, sizeof(T) * vertices.len, unsafeAddr(vertices[0]), GL_STATIC_DRAW)

    shape.send

    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindVertexArray(0)

template draw*[T](self: OglVertexArray[T]) =
    ## Draws a vertex array
    glBindVertexArray(self.id.GLuint)
    glDrawArrays(GL_TRIANGLES, 0, self.vertexCount.GLsizei)
    glBindVertexArray(0)

