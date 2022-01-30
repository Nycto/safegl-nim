import sdl2/sdl

template sdl2assert*(condition: untyped) =
    ## Asserts that an sdl2 related expression is truthy
    let outcome =
        when compiles(condition != 0): condition != 0
        elif compiles(condition == nil): condition == nil:
        else: not condition
    if outcome:
        let msg = astToStr(condition) & "; " & $sdl.getError()
        raise AssertionDefect.newException(msg)

proc getScreenSize*(): tuple[width, height: cint, fullScreenFlag: uint32] =
    ## Determine the size of the display
    when defined(ios):
        var bounds: Rect
        sdl2assert sdl.getDisplayBounds(displayIndex = 0, rect = addr bounds)
        result.width = bounds.w
        result.height = bounds.h
        result.fullScreenFlag = sdl.WindowFullscreen
    else:
        result.width = 640
        result.height = 480
        result.fullScreenFlag = 0

template initialize*(window, screenSize, code: untyped) =
    try:

        # Initialize SDL2 and opengl
        sdl2assert sdl.init(sdl.InitEverything)
        defer: sdl.quit()

        # Ask for a new version of opengl
        sdl2assert sdl.glSetAttribute(GLattr.GL_ACCELERATED_VISUAL, 1)
        sdl2assert sdl.glSetAttribute(GLattr.GL_CONTEXT_MAJOR_VERSION, 3)
        sdl2assert sdl.glSetAttribute(GLattr.GL_CONTEXT_MINOR_VERSION, 0)
        sdl2assert sdl.glSetAttribute(GLattr.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE)

        # Turn on double buffering with a 24bit Z buffer.
        sdl2assert sdl.glSetAttribute(GLattr.GL_DOUBLEBUFFER, 1)
        sdl2assert sdl.glSetAttribute(GLattr.GL_DEPTH_SIZE, 24)

        let screenSize = getScreenSize()

        let window = sdl.createWindow(
            "Example",
            sdl.WindowPosUndefined,
            sdl.WindowPosUndefined,
            w = screenSize.width,
            h = screenSize.height,
            screenSize.fullScreenFlag or sdl.WindowOpenGL or sdl.WindowShown
        )
        sdl2assert window
        defer: window.destroyWindow()

        let glcontext = glCreateContext(window)
        sdl2assert glcontext
        defer: sdl.glDeleteContext(glcontext)

        code
    except:
        sdl.log(getCurrentExceptionMsg().cstring)
        echo getCurrentExceptionMsg()
        raise

template gameLoop*(code: untyped) =
    ## Run the game loop
    var e: sdl.Event
    block endGame:
        while true:
            while sdl.pollEvent(addr e) != 0:
                if e.kind == sdl.Quit:
                    break endGame
            code
