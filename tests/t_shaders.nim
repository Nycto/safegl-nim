import opengl, opengl_tools, options

proc typeCheckMe() =
    let program = createProgram([
        ShaderType.Vertex: some("""
        """),
        ShaderType.Fragment: none(string)
    ])

    program.use

    program.uniform("foo") := [ GLfloat(0.0), GLfloat(0.0), GLfloat(0.0) ]

    program.destroy

