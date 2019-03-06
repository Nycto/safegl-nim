import macros

iterator objFields*(struct: NimNode): tuple[field: string, typeinfo: NimNode] =
    ## Produces the fields in an object declaration

    let declaration = getTypeImpl(struct)[1].getTypeImpl
    expectKind declaration, nnkObjectTy

    for field in declaration[2].children:
        expectKind field, nnkIdentDefs
        expectKind field[0], nnkSym

        yield (field[0].strVal, field[1])

