import opengl, enums, options

# Default values for all hints
const defaultHints = block:
    var defaults: array[OglHint, OglHintMode]
    for hint in low(OglHint)..high(OglHint):
        defaults[hint] = OglHintMode.DontCareMode
    defaults

proc log(messages: string) =
    ## Simple default logging
    echo(messages)

proc initOpenGl*(
    log: proc(messages: string) = log,
    hints: array[OglHint, OglHintMode] = defaultHints,
    flags: set[OglFlag] = {},
    clearDepth: float = 1.0,
    depthFunc: OglDepthFunc = OglDepthFunc.LequalCmp,
    clearColor: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0),
    shadeModel: OglShadeModel = OglShadeModel.SmoothModel,
    sourceBlendFactor: OglBlendFunc = OglBlendFunc.SrcAlphaFunc,
    destinationBlendFactor: OglBlendFunc = OglBlendFunc.OneMinusSrcAlphaFunc,
    screenSize: Option[tuple[width, height: int]] = none(tuple[width, height: int])
) =
    ## Initializes OpenGL

    when not defined(ios):
        loadExtensions()

    # Log a bit of opengl info
    log("OpenGL vendor: " & $cast[cstring](glGetString(GL_VENDOR)))
    log("OpenGL renderer: " & $cast[cstring](glGetString(GL_RENDERER)))
    log("OpenGL Version: " & $cast[cstring](glGetString(GL_VERSION)))
    log("OpenGL shader version: " & $cast[cstring](glGetString(GL_SHADING_LANGUAGE_VERSION)))

    for hint in OglHint:
        if hints[hint] != OglHintMode.DontCareMode:
            glHint(hint.glEnum, hints[hint].glEnum)

    for flag in flags:
        glEnable(flag.glEnum)

    when not defined(ios):
        glShadeModel(shadeModel.glEnum)

    glClearDepthf(clearDepth)
    glDepthFunc(depthFunc.glEnum)
    glBlendFunc(sourceBlendFactor.glEnum, destinationBlendFactor.glEnum)
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a)

    when defined(ios):
        assert(screenSize.isSome)

    if screenSize.isSome:
        glViewport(0, 0, screenSize.get.width.GLsizei, screenSize.get.height.GLsizei)

template clear*(bits: set[OglClear] = { OglClear.ColorBufferBit, OglClear.DepthBufferBit }) =
    ## Clears the given buffers

    var accum: GlBitfield
    for bit in bits:
        accum = accum or bit.glEnum

    glClear(accum)

