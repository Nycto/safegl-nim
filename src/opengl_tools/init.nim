import opengl, enums

# Default values for all hints
const defaultHints = block:
    var defaults: array[OglHint, OglHintMode]
    for hint in low(OglHint)..high(OglHint):
        defaults[hint] = OglHintMode.DontCareMode
    defaults

proc initOpenGl*(
    hints: array[OglHint, OglHintMode] = defaultHints,
    flags: set[OglFlag] = { OglFlag.DepthTestFlag, OglFlag.BlendFlag },
    clearDepth: float = 1.0,
    depthFunc: OglDepthFunc = OglDepthFunc.LequalCmp,
    clearColor: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0),
    shadeModel: OglShadeModel = OglShadeModel.SmoothModel,
    sourceBlendFactor: OglBlendFunc = OglBlendFunc.SrcAlphaFunc,
    destinationBlendFactor: OglBlendFunc = OglBlendFunc.OneMinusSrcAlphaFunc
) =
    ## Initializes OpenGL

    when not defined(ios):
        loadExtensions()

    for hint in low(OglHint)..high(OglHint):
        glHint(hint.glEnum, hints[hint].glEnum)

    for flag in flags:
        glEnable(flag.glEnum)

    glShadeModel(shadeModel.glEnum)
    glClearDepth(clearDepth)
    glDepthFunc(depthFunc.glEnum)
    glBlendFunc(sourceBlendFactor.glEnum, destinationBlendFactor.glEnum)
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a)


