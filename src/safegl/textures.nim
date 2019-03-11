import opengl, enums, stb_image/read as stbi, os

type TextureId* = distinct GLuint ## A texture

proc asInternalFormat*(self: OglTexFormat): OglTexInternalFormat =
    ## Return the internal format that maps to an input texture format
    case self
    of OglTexFormat.Red: OglTexInternalFormat.Red
    of OglTexFormat.RG: OglTexInternalFormat.RG
    of OglTexFormat.Rgb: OglTexInternalFormat.Rgb
    of OglTexFormat.Bgr: OglTexInternalFormat.Bgr
    of OglTexFormat.Rgba: OglTexInternalFormat.Rgba
    of OglTexFormat.Bgra: OglTexInternalFormat.Bgra
    of OglTexFormat.DepthComponent: OglTexInternalFormat.DepthComponent
    of OglTexFormat.DepthStencil: OglTexInternalFormat.DepthStencil

template activate*(textureId: TextureId, slot: OglSlot) =
    ## Activates a texture
    glActiveTexture(slot.glEnum)
    glBindTexture(GL_TEXTURE_2D, textureId.GLuint)

proc newTexture*(
    size: tuple[width, height: int],
    format: OglTexFormat,
    internalFormat: OglTexInternalFormat,
    pixelType: OglPixelType,
    data: pointer,
    target: OglTexTarget = OglTexTarget.Texture2d,
    minFilter: OglTexMinFilter = OglTexMinFilter.Nearest,
    magFilter: OglTexMagFilter = OglTexMagFilter.Linear,
    wrapS: OglTexWrap = OglTexWrap.Repeat,
    wrapT: OglTexWrap = OglTexWrap.Repeat,
): TextureId =
    ## Binds and fills a texture
    var textureId: GLuint
    glGenTextures(1, addr textureId)
    result = TextureId(textureId)

    glBindTexture(GL_TEXTURE_2D, textureId)

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS.glEnum)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT.glEnum)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter.glEnum)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter.glEnum)

    glTexImage2D(
        target.glEnum,
        0,
        internalFormat.glEnum.GLint,
        size.width.GLint,
        size.height.GLint,
        0,
        format.glEnum,
        pixelType.glEnum,
        data
    )

proc newTexture*(
    size: tuple[width, height: int],
    format: OglTexFormat,
    pixelType: OglPixelType,
    data: pointer,
    target: OglTexTarget = OglTexTarget.Texture2d,
    minFilter: OglTexMinFilter = OglTexMinFilter.Nearest,
    magFilter: OglTexMagFilter = OglTexMagFilter.Linear,
    wrapS: OglTexWrap = OglTexWrap.Repeat,
    wrapT: OglTexWrap = OglTexWrap.Repeat,
): TextureId =
    ## Binds and fills a texture
    newTexture(size, format, format.asInternalFormat, pixelType, data, target, minFilter, magFilter, wrapS, wrapT)

proc loadPngTexture*(
    path: string,
    minFilter: OglTexMinFilter = OglTexMinFilter.Nearest,
    magFilter: OglTexMagFilter = OglTexMagFilter.Linear,
    wrapS: OglTexWrap = OglTexWrap.Repeat,
    wrapT: OglTexWrap = OglTexWrap.Repeat,
): TextureId =
    ## Loads a texture from a file
    assert(path.existsFile, "Image does not exist: " & path)

    var width, height, channels: int
    stbi.setFlipVerticallyOnLoad(true)
    var data: seq[uint8] = stbi.load(path, width, height, channels, stbi.Default)

    assert(data.len > 0, "Unable to load image: " & path)

    let format =
        case channels
        of 3: OglTexFormat.Rgb
        of 4: OglTexFormat.Rgba
        else:
            doAssert(false, "Unexpected number of channels: " & $channels)
            OglTexFormat.Rgba

    result = newTexture(
        size = (width, height),
        format = format,
        pixelType = OglPixelType.UnsignedByte,
        data = data[0].addr,
        minFilter = minFilter,
        magFilter = magFilter,
        wrapS = wrapS,
        wrapT = wrapT
    )



