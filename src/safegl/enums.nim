import opengl, macros, strutils, sequtils

proc enumFlag(glConst: NimNode): NimNode =
    ## Convert an opengl constant to a Nim constant
    expectKind glConst, nnkIdent
    var parts = glConst.strVal.split('_')
    parts.delete(0)
    var asString = parts.mapIt(it.toLowerAscii.capitalizeAscii).join()
    result = ident(asString)

proc createEnum(name: NimNode, flags: NimNode): NimNode =
    ## Creates an enum out of opengl constants
    expectKind name, nnkIdent

    var enumFields = nnkEnumTy.newTree(newEmptyNode())
    for flag in flags:
        expectKind flag, nnkIdent
        enumFields.add(flag.enumFlag)

    result = nnkTypeSection.newTree(
        nnkTypeDef.newTree(
            nnkPragmaExpr.newTree(
                nnkPostfix.newTree(newIdentNode("*"), name),
                nnkPragma.newTree(ident("pure"))
            ),
            newEmptyNode(),
            enumFields
        )
    )

proc caseStmt(name, flags, key: NimNode, mapper: proc(flag: NimNode): NimNode): NimNode =
    ## Generates a case statement for each flag
    expectKind name, nnkIdent
    expectKind key, nnkIdent
    result = nnkCaseStmt.newTree(key)
    for flag in flags:
        expectKind flag, nnkIdent
        let caseTest = newDotExpr(name, flag.enumFlag)
        let caseBranch: NimNode = mapper(flag)
        result.add(nnkOfBranch.newTree(caseTest, caseBranch))

proc createToGlProc(name: NimNode, glType, flags: NimNode): NimNode =
    ## Creates a function to convert an enum back to an opengl function
    expectKind name, nnkIdent
    expectKind glType, nnkIdent
    let body = caseStmt(name, flags, ident("key")) do (flag: NimNode) -> NimNode: flag
    result = newProc(postfix(ident("glEnum"), "*"), [ glType, newIdentDefs(ident("key"), name) ], body)

proc createGlConstProc(name: NimNode, flags: NimNode): NimNode =
    ## Creates a function to convert an enum back to an opengl function
    expectKind name, nnkIdent
    let body = caseStmt(name, flags, ident("key")) do (flag: NimNode) -> NimNode: newLit(flag.strVal)
    result = newProc(postfix(ident("glConst"), "*"), [ ident("string"), newIdentDefs(ident("key"), name) ], body)

macro defineOglEnum(name, glType, flags: untyped): untyped =
    ## Create an enum and a toGlConst function
    expectKind name, nnkIdent
    result = newStmtList(
        createEnum(name, flags),
        createToGlProc(name, glType, flags),
        createGlConstProc(name, flags))

defineOglEnum(OglFlag, GlEnum): ## See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glEnable.xml
    GL_POINT_SMOOTH
    GL_LINE_SMOOTH
    GL_LINE_STIPPLE
    GL_POLYGON_SMOOTH
    GL_POLYGON_STIPPLE
    GL_CULL_FACE
    GL_LIGHTING
    GL_COLOR_MATERIAL
    GL_FOG
    GL_DEPTH_TEST
    GL_STENCIL_TEST
    GL_NORMALIZE
    GL_ALPHA_TEST
    GL_DITHER
    GL_BLEND
    GL_INDEX_LOGIC_OP
    GL_COLOR_LOGIC_OP
    GL_SCISSOR_TEST
    GL_TEXTURE_GEN_S
    GL_TEXTURE_GEN_T
    GL_TEXTURE_GEN_R
    GL_TEXTURE_GEN_Q
    GL_AUTO_NORMAL
    GL_MAP1_COLOR_4
    GL_MAP1_INDEX
    GL_MAP1_NORMAL
    GL_MAP1_TEXTURE_COORD_1
    GL_MAP1_TEXTURE_COORD_2
    GL_MAP1_TEXTURE_COORD_3
    GL_MAP1_TEXTURE_COORD_4
    GL_MAP1_VERTEX_3
    GL_MAP1_VERTEX_4
    GL_MAP2_COLOR_4
    GL_MAP2_INDEX
    GL_MAP2_NORMAL
    GL_MAP2_TEXTURE_COORD_1
    GL_MAP2_TEXTURE_COORD_2
    GL_MAP2_TEXTURE_COORD_3
    GL_MAP2_TEXTURE_COORD_4
    GL_MAP2_VERTEX_3
    GL_MAP2_VERTEX_4
    GL_TEXTURE_1D
    GL_TEXTURE_2D
    GL_POLYGON_OFFSET_POINT
    GL_POLYGON_OFFSET_LINE
    GL_CONVOLUTION_1D
    GL_CONVOLUTION_2D
    GL_SEPARABLE_2D
    GL_HISTOGRAM
    GL_MINMAX
    GL_POLYGON_OFFSET_FILL
    GL_RESCALE_NORMAL
    GL_TEXTURE_3D
    GL_MULTISAMPLE
    GL_SAMPLE_ALPHA_TO_COVERAGE
    GL_SAMPLE_ALPHA_TO_ONE
    GL_SAMPLE_COVERAGE
    GL_COLOR_TABLE
    GL_POST_CONVOLUTION_COLOR_TABLE
    GL_POST_COLOR_MATRIX_COLOR_TABLE
    GL_COLOR_SUM
    GL_TEXTURE_CUBE_MAP
    GL_VERTEX_PROGRAM_POINT_SIZE
    GL_VERTEX_PROGRAM_TWO_SIDE
    GL_POINT_SPRITE

defineOglEnum(OglHintMode, GlEnum): ## See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glHint.xml
    GL_DONT_CARE
    GL_FASTEST
    GL_NICEST

defineOglEnum(OglHint, GlEnum): ## See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glHint.xml
    GL_PERSPECTIVE_CORRECTION_HINT
    GL_POINT_SMOOTH_HINT
    GL_LINE_SMOOTH_HINT
    GL_POLYGON_SMOOTH_HINT
    GL_FOG_HINT
    GL_GENERATE_MIPMAP_HINT
    GL_TEXTURE_COMPRESSION_HINT
    GL_FRAGMENT_SHADER_DERIVATIVE_HINT

defineOglEnum(OglDepthFunc, GlEnum): ## See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glDepthFunc.xml
    GL_NEVER
    GL_LESS
    GL_EQUAL
    GL_LEQUAL
    GL_GREATER
    GL_NOTEQUAL
    GL_GEQUAL
    GL_ALWAYS

defineOglEnum(OglShadeModel, GlEnum): ## See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glShadeModel.xml
    GL_FLAT
    GL_SMOOTH

defineOglEnum(OglBlendFunc, GlEnum):
    GL_ZERO
    GL_ONE
    GL_SRC_COLOR
    GL_ONE_MINUS_SRC_COLOR
    GL_DST_COLOR
    GL_ONE_MINUS_DST_COLOR
    GL_SRC_ALPHA
    GL_ONE_MINUS_SRC_ALPHA
    GL_DST_ALPHA
    GL_ONE_MINUS_DST_ALPHA
    GL_CONSTANT_COLOR
    GL_ONE_MINUS_CONSTANT_COLOR
    GL_CONSTANT_ALPHA
    GL_ONE_MINUS_CONSTANT_ALPHA
    GL_SRC_ALPHA_SATURATE

defineOglEnum(OglShaderType, GlEnum):
    GL_VERTEX_SHADER
    GL_FRAGMENT_SHADER

defineOglEnum(OglType, GlEnum):
    cGL_BYTE
    cGL_UNSIGNED_BYTE
    cGL_SHORT
    cGL_UNSIGNED_SHORT
    cGL_INT
    cGL_FLOAT
    cGL_DOUBLE

defineOglEnum(OglClear, GlBitfield):
    GL_COLOR_BUFFER_BIT
    GL_DEPTH_BUFFER_BIT
    GL_ACCUM_BUFFER_BIT
    GL_STENCIL_BUFFER_BIT

