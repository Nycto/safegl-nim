import macros, ../enums, types

proc fnSuffix(dataType: OglType, sourceNode: NimNode): string =
    ## Given an opengl type, returns the suffix to use for function calls
    case dataType
    of OglType.Byte, OglType.Short, OglType.Double, OglType.UnsignedByte, OglType.UnsignedShort:
        error("Data type is not currently supported for uniforms: " & $dataType, sourceNode)
        ""
    of OglType.Int: "i"
    of OglType.Float: "f"

proc setUniformPrimitive(typeinfo: TypeStructure, getUniformId: NimNode, value: NimNode): NimNode =
    ## Creates a function call to set a uniform from a primitive
    assert(typeinfo.kind == TypeKind.Primitive)
    result = newCall(ident("glUniform1" & typeinfo.dataType.fnSuffix(value)), getUniformId, value)

proc `[]`(a, b: NimNode): NimNode =
    ## Produces a NimNode of a[b]
    nnkBracketExpr.newTree(a, b)

proc setUniformVector(typeinfo: TypeStructure, getUniformId: NimNode, value: NimNode): NimNode =
    assert(typeinfo.category == TypeCategory.Vector)
    assert(typeinfo.totalCount > 0 and typeinfo.totalCount <= 4)
    let fn = "glUniform" & $typeinfo.totalCount & typeinfo.coreType.fnSuffix(value) & "v"
    result = newCall(
        ident(fn),
        getUniformId,
        newLit(1),
        newCall("unsafeAddr", value[newLit(0)])
    )

proc setUniformMatrix(typeinfo: TypeStructure, getUniformId: NimNode, value: NimNode): NimNode =
    assert(typeinfo.category == TypeCategory.Matrix)
    assert(typeinfo.totalCount >= 4 and typeinfo.totalCount <= 16)
    assert(typeinfo.coreType == OglType.Float)

    let fnType =
        if typeinfo.count == typeinfo.nested.count:
            $typeinfo.count
        else:
            $typeinfo.nested.count & "x" & $typeinfo.count

    result = newCall(
        ident("glUniformMatrix" & fnType & "fv"),
        getUniformId,
        newLit(1),
        ident("GL_TRUE"), # The matrices are in row major order
        newCall("unsafeAddr", value[newLit(0)][newLit(0)])
    )

macro setUniforms*(shape, programId: typed, values: untyped): untyped =
    ## Creates method calls for setting uniforms from a type
    result = newStmtList()

    for field in fields(shape):
        let getUniformId = newCall(ident("glGetUniformLocation"), programId, newLit(field.name))
        let readField = newDotExpr(values, ident(field.name))

        let struct = field.structure

        let setter =
            case struct.category
            of TypeCategory.Primitive: setUniformPrimitive(struct, getUniformId, readField)
            of TypeCategory.Vector: setUniformVector(struct, getUniformId, readField)
            of TypeCategory.Matrix: setUniformMatrix(struct, getUniformId, readField)
            of TypeCategory.Other:
                error(
                    "Could not set uniform for field: " & field.name & ". Type is too complex. " &
                    "Make sure you're using the GL* types (For example, GLvectorf3)",
                    shape
                )
                newStmtList()

        result.add(setter)
