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

defineOglEnum(OglTexTarget, GlEnum):
    GL_TEXTURE_2D
    GL_PROXY_TEXTURE_2D
    GL_TEXTURE_1D_ARRAY
    GL_PROXY_TEXTURE_1D_ARRAY
    GL_TEXTURE_RECTANGLE
    GL_PROXY_TEXTURE_RECTANGLE
    GL_TEXTURE_CUBE_MAP_POSITIVE_X
    GL_TEXTURE_CUBE_MAP_NEGATIVE_X
    GL_TEXTURE_CUBE_MAP_POSITIVE_Y
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
    GL_TEXTURE_CUBE_MAP_POSITIVE_Z
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
    GL_PROXY_TEXTURE_CUBE_MAP

defineOglEnum(OglTexFormat, GlEnum):
    GL_RED
    GL_RG
    GL_RGB
    GL_BGR
    GL_RGBA
    GL_BGRA
    GL_DEPTH_COMPONENT
    GL_DEPTH_STENCIL

defineOglEnum(OglTexInternalFormat, GlEnum):
    GL_RED
    GL_RG
    GL_RGB
    GL_BGR
    GL_RGBA
    GL_BGRA
    GL_DEPTH_COMPONENT
    GL_DEPTH_STENCIL
    GL_R8
    GL_R8_SNORM
    GL_R16
    GL_R16_SNORM
    GL_RG8
    GL_RG8_SNORM
    GL_RG16
    GL_RG16_SNORM
    GL_R3_G3_B2
    GL_RGB4
    GL_RGB5
    GL_RGB8
    GL_RGB8_SNORM
    GL_RGB10
    GL_RGB12
    GL_RGB16_SNORM
    GL_RGBA2
    GL_RGBA4
    GL_RGB5_A1
    GL_RGBA8
    GL_RGBA8_SNORM
    GL_RGB10_A2
    GL_RGB10_A2UI
    GL_RGBA12
    GL_RGBA16
    GL_SRGB8
    GL_SRGB8_ALPHA8
    GL_R16F
    GL_RG16F
    GL_RGB16F
    GL_RGBA16F
    GL_R32F
    GL_RG32F
    GL_RGB32F
    GL_RGBA32F
    GL_R11F_G11F_B10F
    GL_RGB9_E5
    GL_R8I
    GL_R8UI
    GL_R16I
    GL_R16UI
    GL_R32I
    GL_R32UI
    GL_RG8I
    GL_RG8UI
    GL_RG16I
    GL_RG16UI
    GL_RG32I
    GL_RG32UI
    GL_RGB8I
    GL_RGB8UI
    GL_RGB16I
    GL_RGB16UI
    GL_RGB32I
    GL_RGB32UI
    GL_RGBA8I
    GL_RGBA8UI
    GL_RGBA16I
    GL_RGBA16UI
    GL_RGBA32I
    GL_RGBA32UI
    GL_COMPRESSED_RED
    GL_COMPRESSED_RG
    GL_COMPRESSED_RGB
    GL_COMPRESSED_RGBA
    GL_COMPRESSED_SRGB
    GL_COMPRESSED_SRGB_ALPHA
    GL_COMPRESSED_RED_RGTC1
    GL_COMPRESSED_SIGNED_RED_RGTC1
    GL_COMPRESSED_RG_RGTC2
    GL_COMPRESSED_SIGNED_RG_RGTC2

defineOglEnum(OglPixelType, GlEnum):
    cGL_UNSIGNED_BYTE
    cGL_BYTE
    cGL_UNSIGNED_SHORT
    cGL_SHORT
    GL_UNSIGNED_INT
    cGL_INT
    GL_HALF_FLOAT
    cGL_FLOAT
    GL_UNSIGNED_BYTE_3_3_2
    GL_UNSIGNED_BYTE_2_3_3_REV
    GL_UNSIGNED_SHORT_5_6_5
    GL_UNSIGNED_SHORT_5_6_5_REV
    GL_UNSIGNED_SHORT_4_4_4_4
    GL_UNSIGNED_SHORT_4_4_4_4_REV
    GL_UNSIGNED_SHORT_5_5_5_1
    GL_UNSIGNED_SHORT_1_5_5_5_REV
    GL_UNSIGNED_INT_8_8_8_8
    GL_UNSIGNED_INT_8_8_8_8_REV
    GL_UNSIGNED_INT_10_10_10_2
    GL_UNSIGNED_INT_2_10_10_10_REV

defineOglEnum(OglTexMinFilter, GlInt):
    GL_NEAREST
    GL_LINEAR
    GL_NEAREST_MIPMAP_NEAREST
    GL_LINEAR_MIPMAP_NEAREST
    GL_NEAREST_MIPMAP_LINEAR
    GL_LINEAR_MIPMAP_LINEAR

defineOglEnum(OglTexMagFilter, GlInt):
    GL_NEAREST
    GL_LINEAR

defineOglEnum(OglTexWrap, GlInt):
    GL_CLAMP_TO_EDGE
    GL_MIRRORED_REPEAT
    GL_REPEAT

defineOglEnum(OglSlot, GLenum):
    GL_TEXTURE0
    GL_TEXTURE1
    GL_TEXTURE2
    GL_TEXTURE3
    GL_TEXTURE4
    GL_TEXTURE5
    GL_TEXTURE6
    GL_TEXTURE7
    GL_TEXTURE8
    GL_TEXTURE9
    GL_TEXTURE10
    GL_TEXTURE11
    GL_TEXTURE12
    GL_TEXTURE13
    GL_TEXTURE14
    GL_TEXTURE15

