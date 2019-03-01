import safegl

proc typeCheckMe() =
    initOpenGl()
    clear({ OglClear.ColorBufferBit, OglClear.DepthBufferBit })

