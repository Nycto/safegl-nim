import opengl, macros

type GLvectorb2* = array[2, GLbyte]

macro createConverter(inputType, outputType, glVectorRoot: untyped): untyped =
    ## Creates conversion methods for interop between nim native types and OpenGL types
    expectKind inputType, nnkIdent
    expectKind outputType, nnkIdent
    expectKind glVectorRoot, nnkIdent

    result = newStmtList()
    for i in 2..4:

        let vectorType = ident(glVectorRoot.strVal & $i)

        # Add an export statement
        result.add(nnkExportStmt.newTree(vectorType, outputType))

        let elements = nnkBracket.newTree()

        # Add the convert method
        result.add(nnkConverterDef.newTree(
            postfix(ident("to" & vectorType.strVal), "*"),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                vectorType,
                nnkIdentDefs.newTree(
                    ident("input"),
                    nnkBracketExpr.newTree(ident("array"), newLit(i), inputType),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            newStmtList(
                newCommentStmtNode("Convert an array of " & inputType.strVal & " to a vector of " & outputType.strVal),
                elements
            )
        ))

        for elem in 0..(i-1):
            elements.add(newDotExpr(nnkBracketExpr.newTree(ident("input"), newLit(elem)), outputType))

createConverter(SomeFloat, GLfloat, GLvectorf)
createConverter(SomeInteger, GLfloat, GLvectorf)
createConverter(SomeInteger, GLint, GLvectori)
createConverter(SomeInteger, GLbyte, GLvectorb)
createConverter(SomeInteger, GLubyte, GLvectorub)

