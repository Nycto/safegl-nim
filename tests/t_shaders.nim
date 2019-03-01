import opengl, safegl

proc typeCheckMe() =
    let program = createProgram([
        OglShaderType.VertexShader: @[ "" ],
        OglShaderType.FragmentShader: @[]
    ])

    program.use

    program.uniform("foo") := [ GLfloat(0.0), GLfloat(0.0), GLfloat(0.0) ]

    program.destroy

