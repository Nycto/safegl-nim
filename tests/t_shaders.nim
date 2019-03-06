import opengl, safegl

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

proc typeCheckMe() =
    let program = createProgram[MyUniforms]([
        OglShaderType.VertexShader: @[ "" ],
        OglShaderType.FragmentShader: @[]
    ])

    var uniforms: MyUniforms

    program.use(uniforms)

    program.destroy

