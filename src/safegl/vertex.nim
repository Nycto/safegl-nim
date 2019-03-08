import enums, opengl, sequtils, macros, strutils, private/reflection, private/types

type
    OglVertexArrayId = distinct GLuint

    OglVertexBufferId = distinct GLuint

    OglVertexArray*[T] = object
        id: OglVertexArrayId
        buffers: seq[OglVertexBufferId]
        vertexCount: int

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

macro defineAttribs(shape: typed): untyped =
    ## Sends vertex attribute shapes over to opengl
    result = newStmtList()

    var i = 0
    var offset = 0.int64
    for attrib in fields(shape):
        let struct = attrib.structure

        result.add(
            newCall(
                ident("glVertexAttribPointer"),
                newLit(i),
                newLit(struct.totalCount.int),
                ident(struct.coreType.glConst),
                ident("GL_FALSE"),
                newDotExpr(newCall(ident("sizeof"), shape), ident("GLsizei")),
                nnkCast.newTree(ident("GLvoid"), newLit(offset.int))
            ),
            newCall(ident("glEnableVertexAttribArray"), newDotExpr(newLit(i), ident("GLuint")))
        )

        offset += struct.totalCount * struct.coreType.size
        i += 1

proc newVertexArray*[T](vertices: openarray[T]): OglVertexArray[T] =
    ## Creates a vertex array instance
    result.id = genVertexArray().bindArray()
    result.buffers.add(genVertexBuffer().bindBuffer())
    result.vertexCount = vertices.len

    glBufferData(GL_ARRAY_BUFFER, sizeof(T) * vertices.len, unsafeAddr(vertices[0]), GL_STATIC_DRAW)

    defineAttribs(T)

    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindVertexArray(0)

template draw*[T](self: OglVertexArray[T]) =
    ## Draws a vertex array
    glBindVertexArray(self.id.GLuint)
    glDrawArrays(GL_TRIANGLES, 0, self.vertexCount.GLsizei)
    glBindVertexArray(0)

