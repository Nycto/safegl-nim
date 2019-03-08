import safegl, opengl, sdl2/sdl, options, times, sdl2util

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

initialize(window, screenSize):

    initOpenGl(screenSize = some((screenSize.width.int, screenSize.height.int)))

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

