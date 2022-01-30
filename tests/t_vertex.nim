import opengl, safegl, unittest

type MyVertex = object
    value: GLint
    position: GLvectorf3
    color: GLvectorf4
    grid: GLmatrixd4
    nested: array[3, array[4, array[5, array[6, GLint]]]]

test "Vertex APIs compile":
    check:
        compiles:

            let blue = [0.0,  0.0, 1.0, 1.0]
            let black = [0.0,  0.0, 0.0, 1.0]
            let white = [1.0,  1.0, 1.0, 1.0]
            let red = [1.0,  0.0, 0.0, 1.0]
            let purple = [1.0,  0.0, 1.0, 1.0]
            let green = [0.0,  1.0, 0.0, 1.0]
            let cyan = [0.0, 1.0, 1.0, 1.0]
            let yellow = [1.0, 1.0, 0.0, 1.0]

            let vao = newVertexArray([
                # vertices for the front face of the cube
                MyVertex(position: [-0.5, -0.5, 0.5],     color: blue),
                MyVertex(position: [0.5, -0.5, 0.5],      color: purple),
                MyVertex(position: [0.5, 0.5, 0.5],       color: white),

                MyVertex(position: [-0.5, 0.5, 0.5],      color: cyan),
                MyVertex(position: [0.5, 0.5, 0.5],       color: white),
                MyVertex(position: [-0.5, -0.5, 0.5],     color: blue),

                # vertices for the right face of the cube
                MyVertex(position: [0.5, 0.5, 0.5],       color: white),
                MyVertex(position: [0.5, 0.5, -0.5],      color: yellow),
                MyVertex(position: [0.5, -0.5, -0.5],     color: red),

                MyVertex(position: [0.5, 0.5, 0.5],       color: white),
                MyVertex(position: [0.5, -0.5, -0.5],     color: red),
                MyVertex(position: [0.5, -0.5, 0.5],      color: purple),

                # vertices for the back face of the cube
                MyVertex(position: [-0.5, -0.5, -0.5],    color: black),
                MyVertex(position: [0.5, -0.5, -0.5],     color: red),
                MyVertex(position: [0.5, 0.5, -0.5],      color: yellow),

                MyVertex(position: [-0.5, -0.5, -0.5],    color: black),
                MyVertex(position: [0.5, 0.5, -0.5],      color: yellow),
                MyVertex(position: [-0.5, 0.5, -0.5],     color: green),

                # vertices for the left face of the cube
                MyVertex(position: [-0.5, -0.5, -0.5],    color: black),
                MyVertex(position: [-0.5, -0.5, 0.5],     color: blue),
                MyVertex(position: [-0.5, 0.5, 0.5],      color: cyan),

                MyVertex(position: [-0.5, -0.5, -0.5],    color: black),
                MyVertex(position: [-0.5, 0.5, 0.5],      color: cyan),
                MyVertex(position: [-0.5, 0.5, -0.5],     color: green),

                # vertices for the upper face of the cube
                MyVertex(position: [0.5, 0.5, 0.5],       color: white),
                MyVertex(position: [-0.5, 0.5, 0.5],      color: cyan),
                MyVertex(position: [0.5, 0.5, -0.5],      color: yellow),

                MyVertex(position: [-0.5, 0.5, 0.5],      color: cyan),
                MyVertex(position: [0.5, 0.5, -0.5],      color: yellow),
                MyVertex(position: [-0.5, 0.5, -0.5],     color: green),

                # vertices for the bottom face of the cube
                MyVertex(position: [-0.5, -0.5, -0.5],    color: black),
                MyVertex(position: [0.5, -0.5, -0.5],     color: red),
                MyVertex(position: [-0.5, -0.5, 0.5],     color: blue),

                MyVertex(position: [0.5, -0.5, -0.5],     color: red),
                MyVertex(position: [-0.5, -0.5, 0.5],     color: blue),
                MyVertex(position: [0.5, -0.5, 0.5],      color: purple),
            ])

            discard $vao

            vao.draw
