import opengl, safegl, unittest

suite "Generated enums":

    test "Return their constant values":
        check(OglFlag.PointSmooth.glEnum == GL_POINT_SMOOTH)
        check(OglType.Float.glEnum == cGL_FLOAT)

    test "Produce string versions":
        check(OglFlag.PointSmooth.glConst == "GL_POINT_SMOOTH")
        check(OglType.Float.glConst == "cGL_FLOAT")

