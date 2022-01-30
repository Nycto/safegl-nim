import safegl, unittest

test "Texture loading compiles":
    check:
        compiles:
            var data: pointer

            discard newTexture(
                size = (10, 20),
                format = OglTexFormat.Rgba,
                pixelType = OglPixelType.UnsignedByte, data
            )

            discard loadPngTexture("foo.png")
