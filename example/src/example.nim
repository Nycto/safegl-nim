import safegl, opengl, sdl2/sdl, options, times, sdl2util

proc loadTexture(path: string): auto =
    ## Loads a texture and returns the texture identifier

    # Load a texture
    let surface = sdl.loadBMP(path)
    defer: sdl.freeSurface(surface)

    result = newTexture(
        size = (surface.w.int, surface.h.int),
        format = if surface.format.BytesPerPixel == 4: OglTexFormat.Rgba else: OglTexFormat.Rgb,
        pixelType = OglPixelType.UnsignedByte,
        surface.pixels
    )

# A basic vertex shader that just forwards the vector position
const vertexShader = """
#version 300 es

layout(location = 0) in mediump vec3 position;
layout(location = 1) in lowp vec4 in_color;
layout(location = 2) in mediump vec2 in_tex_coord;

out vec4 color;
out vec2 tex_coord;

void main() {
    color = in_color;
    tex_coord = in_tex_coord;
    gl_Position = vec4(position, 1.0);
}
"""

# A basic fragment shader that sets the color to orange
const fragmentShader = """
#version 300 es

out lowp vec4 frag_color;

in lowp vec4 color;
in mediump vec2 tex_coord;

uniform lowp float time;
uniform sampler2D tex;

void main() {
    frag_color = mix(texture(tex, tex_coord), color * vec4(vec3(sin(time) * 1.0 + 1.2), 1.0), 0.5);
}
"""

type MyVertex = object ## An object to represent each vertex
    position: GLvectorf3
    color: Glvectorf4
    texCoord: GLvectorf2

# Individual Vertices of a quad
let topLeft =       MyVertex(position: [-0.5,   0.5, 0.0  ], color: [ 1.0, 0.0, 0.0, 1.0 ], texCoord: [ 0.0, 1.0 ])
let bottomLeft =    MyVertex(position: [-0.5,  -0.5, 0.0  ], color: [ 0.0, 1.0, 0.0, 1.0 ], texCoord: [ 0.0, 0.0 ])
let topRight =      MyVertex(position: [ 0.5,   0.5, 0.0  ], color: [ 0.0, 1.0, 0.0, 1.0 ], texCoord: [ 1.0, 1.0 ])
let bottomRight =   MyVertex(position: [ 0.5,  -0.5, 0.0  ], color: [ 0.0, 0.0, 1.0, 1.0 ], texCoord: [ 1.0, 0.0 ])

# Triangles of a quad
let vertices = [ topLeft, bottomLeft, bottomRight, bottomRight, topRight, topLeft ]

type MyUniforms = object ## An object to describe the uniform inputs to a shader program
    time: GLfloat

initialize(window, screenSize):

    initOpenGl(
        screenSize = some((screenSize.width.int, screenSize.height.int)),
        flags = { OglFlag.Texture2d }
    )

    # Build and compile our shader program
    let program = createProgram[MyUniforms, MyVertex](vertexShader, fragmentShader)

    let quad = newVertexArray(vertices)

    var uniforms = MyUniforms(time: 0.0)

    let texture = loadTexture("resources/crate.bmp")

    let start = epochTime()

    gameLoop:
        uniforms.time = epochTime() - start

        # Reset the scene
        clear()

        # Draw the triangle
        program.use(uniforms)
        texture.activate(OglSlot.Texture0)
        quad.draw

        # Swap in the new rendering
        window.glSwapWindow()

