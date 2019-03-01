import opengl, enums

type
    ShaderError* = object of Defect ## Unrecoverable errors in a shader

    ShaderId* = distinct GLuint ## Identifies an individual shader

    ShaderProgramId* = distinct GLuint ## Identifies a program of shaders

    ShaderProgram* = object ## A shader program and the associated shader IDs
        shaders: seq[ShaderId]
        programId: ShaderProgramId

    Uniform* = distinct GLint ## A uniform value passed to the shaders

template getError(id: typed, ivFn, logFn: untyped): string =
    ## Returns the error message associated with an operation
    var logSize: GLint
    ivFn(GLuint(id), GL_INFO_LOG_LENGTH, logSize.addr)
    var logStr = cast[ptr GLchar](alloc(logSize))
    defer: dealloc(logStr)
    logFn(GLuint(id), logSize.GLsizei, nil, logStr)
    $logStr

template isFailed(id: typed, ivFn: untyped, statusConst: typed): bool =
    ## Checks a status function for failure
    var status: GLint
    ivFn(id, statusConst, status.addr)
    not status.bool

template assertSuccess(id: typed, ivFn, statusConst, logFn, message: untyped) =
    ## Asserts the success of an opengl operation
    if isFailed(id, ivFn, statusConst):
        let log = getError(id, ivFn, logFn)
        raise ShaderError.newException(message & log)

proc create*(shaderType: OglShaderType, src: string): ShaderId =
    ## Compiles and creates an OpenGL shader
    let shaderCString = allocCStringArray([src])
    defer: deallocCStringArray(shaderCString)

    let shaderId = glCreateShader(shaderType.glEnum)
    result = shaderId.ShaderId

    glShaderSource(shaderId, 1, shaderCString, nil)
    glCompileShader(shaderId)
    assertSuccess(shaderId, glGetShaderiv, GL_COMPILE_STATUS, glGetShaderInfoLog, src & " wasn't compiled.\n")

proc destroy*(shaderId: ShaderId) =
    ## Destroys ashader
    glDeleteShader(GLuint(shaderId))

proc createProgram*(shaderIds: varargs[ShaderId]): ShaderProgram =
    ## Creates a shader program
    let programId = glCreateProgram()
    result.programId = programId.ShaderProgramId

    for shaderId in shaderIds:
        result.shaders.add(shaderId)
        glAttachShader(programId, GLuint(shaderId))

    glLinkProgram(programId)
    assertSuccess(programId, glGetProgramiv, GL_LINK_STATUS, glGetProgramInfoLog, "Program linking failed: ")

proc createProgram*(shaders: array[OglShaderType, seq[string]]): ShaderProgram =
    ## Creates a program out of a suite of shader sources

    var shaderIds: seq[ShaderId]
    for shaderType, sources in shaders:
        for source in sources:
            shaderIds.add(shaderType.create(source))

    result = createProgram(shaderIds)

template use*(program: ShaderProgram) =
    ## Uses a specific program
    glUseProgram(GLuint(program.programId))

template destroy*(program: ShaderProgram) =
    ## Uses a specific program
    glDeleteProgram(GLuint(program.programId))
    for shader in program.shaders:
        shader.destroy

template uniform*(program: ShaderProgram, uniformName: string): Uniform =
    ## Returns the uniform for a value
    glGetUniformLocation(GLuint(program.programId), uniformName).Uniform

template `:=`*(uniform: Uniform, vector: GLvectorf3) =
    ## Stores a vector in a uniform
    glUniform3f(uniform.GLint, vector[0], vector[1], vector[2])

template `:=`*(uniform: Uniform, vector: GLmatrixf4) =
    ## Stores a vector in a uniform
    glUniformMatrix4fv(uniform.GLint, 1, false, unsafeAddr vector[0][0])

