# Package

version       = "0.1.0"
author        = "Nycto"
description   = "Example safegl usage"
license       = "MIT"
srcDir        = "src"
bin           = @["example"]


# Dependencies

requires "nim >= 0.19.2", "safegl", "opengl >= 1.2.0", "sdl2_nim >= 2.0.8.0"
