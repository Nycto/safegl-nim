import opengl, safegl

type MyVertex = object
    position: GLvectorf3

type MyUniforms = object ## An object to describe the uniform inputs to a shader program
    myGlInt: GLint
    myGlFloat: GLfloat

    myGlVectori2: GLvectori2
    myGlVectorf2: GLvectorf2
    myGlVectori3: GLvectori3
    myGlVectorf3: GLvectorf3
    myGlVectori4: GLvectori4
    myGlVectorf4: GLvectorf4

    myGlMatrixf2x2: array[2, array[2, GLfloat]]
    myGlMatrixf2x3: array[3, array[2, GLfloat]]
    myGlMatrixf2x4: array[4, array[2, GLfloat]]
    myGlMatrixf3x2: array[3, array[2, GLfloat]]
    myGlMatrixf3: GLmatrixf3
    myGlMatrixf3x4: array[4, array[3, GLfloat]]
    myGlMatrixf4x2: array[2, array[4, GLfloat]]
    myGlMatrixf4x3: array[3, array[4, GLfloat]]
    myGlMatrixf4: GLmatrixf4

proc typeCheckLinkProgram() =
    discard linkProgram[MyUniforms, MyVertex, 1]([
        OglShaderType.VertexShader.create("...")
    ])

proc typeCheckCompileProgram() =
    discard compileProgram[MyUniforms, MyVertex, 1]([
        OglShaderType.VertexShader: @[ "..." ],
        OglShaderType.FragmentShader: @[]
    ])

proc typeCheckCreateProgram() =
    discard createProgram[MyUniforms, MyVertex, 1]("...", "...")

proc typeCheckMeFullPipeline() =
    let program = createProgram[MyUniforms, MyVertex, 2]("...", "...")

    let vao = newVertexArray([
        MyVertex(position: [-0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, 0.5, 0.5]),
    ])

    let texture1 = loadPngTexture("foo.png")
    let texture2 = loadPngTexture("bar.png")

    var uniforms: MyUniforms

    program.draw(uniforms, [
        (vao, [ texture1, texture2 ]),
        (vao, [ texture1, texture2 ]),
        (vao, [ texture1, texture2 ]),
    ])

    program.destroy

proc typeCheckDrawOneTexture() =
    let program = createProgram[MyUniforms, MyVertex, 1]("...", "...")

    let vao = newVertexArray([
        MyVertex(position: [-0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, 0.5, 0.5]),
    ])

    let texture = loadPngTexture("foo.png")

    var uniforms: MyUniforms

    program.draw(uniforms, [ (vao, texture), (vao, texture), (vao, texture) ])

    program.destroy

proc typeCheckDrawNoTexture() =
    let program = createProgram[MyUniforms, MyVertex, 0]("...", "...")

    let vao = newVertexArray([
        MyVertex(position: [-0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, -0.5, 0.5]),
        MyVertex(position: [0.5, 0.5, 0.5]),
    ])

    var uniforms: MyUniforms

    program.draw(uniforms, [ vao, vao, vao ])

    program.destroy


