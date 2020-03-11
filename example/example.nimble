# Package

version       = "0.1.0"
author        = "Nycto"
description   = "Example safegl usage"
license       = "MIT"
srcDir        = "src"
bin           = @["example"]


# Dependencies

requires "nim >= 1.0.6", "safegl", "opengl >= 1.2.3", "sdl2_nim >= 2.0.10.0"
