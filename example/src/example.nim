import safegl, opengl, sdl2/sdl, options, times

template sdl2assert(condition: untyped) =
    ## Asserts that an sdl2 related expression is truthy
    let outcome =
        when compiles(condition != 0): condition != 0
        elif compiles(condition == nil): condition == nil:
        else: not condition
    if outcome:
        let msg = astToStr(condition) & "; " & $sdl.getError()
        raise AssertionError.newException(msg)

proc getScreenSize(): tuple[width, height: cint, fullScreenFlag: uint32] =
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

template initialize(window, code: untyped) =
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

        initOpenGl(screenSize = some((screenSize.width.int, screenSize.height.int)))

        code
    except:
        sdl.log(getCurrentExceptionMsg())
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

# A basic vertex shader that just forwards the vector position
const vertexShader = """
#version 300 es
layout(location = 0) in mediump vec3 position;
layout(location = 1) in lowp vec4 in_color;
out vec4 color;
void main() {
    color = in_color;
    gl_Position = vec4(position, 1.0);
}
"""

# A basic fragment shader that sets the color to orange
const fragmentShader = """
#version 300 es
layout(location = 0) out lowp vec4 frag_color;
in lowp vec4 color;
uniform lowp float time;
void main() {
    frag_color = color * vec4(vec3(sin(time) * 2.0 + 2.2), 1.0);
}
"""

type MyVertex = object ## An object to represent each vertex
    position: GLvectorf3
    color: Glvectorf4

# Vertices of a triangle
let vertices = [
    MyVertex(position: [-0.5, -0.5, 0.0 ], color: [ 1.0, 0.0, 0.0, 1.0 ]),  # left
    MyVertex(position: [0.5, -0.5, 0.0  ], color: [ 0.0, 1.0, 0.0, 1.0 ]),  # right
    MyVertex(position: [0.0,  0.5, 0.0  ], color: [ 0.0, 0.0, 1.0, 1.0 ]),  # top
]

type MyUniforms = object ## An object to describe the uniform inputs to a shader program
    time: GLfloat

initialize(window):

    # Build and compile our shader program
    let program = createProgram[MyUniforms, MyVertex](vertexShader, fragmentShader)

    let vao = newVertexArray(vertices)

    let start = epochTime()

    var uniforms = MyUniforms(time: 0.0)

    gameLoop:
        uniforms.time = epochTime() - start

        # Reset the scene
        clear()

        # Draw the triangle
        program.draw(uniforms, vao)

        # Swap in the new rendering
        window.glSwapWindow()

