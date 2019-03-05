import macros

iterator objFields*(struct: NimNode): tuple[field: string, typeinfo: NimNode] =
    ## Produces the fields in an object declaration

    let declaration = getTypeImpl(struct)[1].getTypeImpl
    expectKind declaration, nnkObjectTy

    for field in declaration[2].children:
        expectKind field, nnkIdentDefs
        expectKind field[0], nnkSym

        yield (field[0].strVal, field[1])

proc getRangeSize*(range: NimNode): BiggestInt =
    ## Given a range node (0..2, for example), return how big it is
    expectKind range, nnkInfix
    assert(range[0].strVal == "..")
    expectKind range[1], nnkIntLit
    expectKind range[2], nnkIntLit
    result = range[2].intVal - range[1].intVal + 1

