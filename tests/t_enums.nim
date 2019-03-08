import opengl, safegl, unittest

suite "Generated enums":

    test "Return their constant values":
        check(OglFlag.PointSmoothFlag.glEnum == GL_POINT_SMOOTH)
        check(OglType.FloatType.glEnum == cGL_FLOAT)

    test "Produce string versions":
        check(OglFlag.PointSmoothFlag.glConst == "GL_POINT_SMOOTH")
        check(OglType.FloatType.glConst == "cGL_FLOAT")

