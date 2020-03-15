# SafeGL

SafeGL is a lightweight wrapper around OpenGL that provides type safe guarantees
without adding overhead.

## Type Safety

SafeGL integrates deeply with the Nim type system, translating object types
directly into vertex attributes and uniform setters. This frees you from
fiddling with any of the cryptic arguments associated with OpenGL function
calls.

If your program compiles, your app should render. And if it doesn't, you should
get a descriptive error message telling you why.

* Uses Enums instead of arbitrary constants
* Distinct types for all IDs
* Uses macros to automatically bind Nim objects into things like Vertex Buffers
  and Uniforms
* Basic texture loading methods
* Abstraction for compiling and using shaders

## Example

For a fully functioning example, [look here](https://github.com/Nycto/safegl-nim/blob/master/example/src/example.nim)

# License

This library is released under the MIT License, which is pretty spiffy. You
should have received a copy of the MIT License along with this program. If not,
see http://www.opensource.org/licenses/mit-license.php

