import ../enums, opengl, macros, strutils, sequtils, reflection

type
    TypeKind* {.pure .} = enum ## For nested type structures, describes whether its a leaf or contains another array
        Primitive,
        Array

    TypeStructure* = ref object ## Describes the types of data that can be passed to opengl
        case kind*: TypeKind
        of TypeKind.Primitive:
            dataType*: OglType
        of TypeKind.Array:
            count*: BiggestInt
            nested*: TypeStructure

    TypeField* = ref object ## Describes a field in an object
        name*: string
        structure*: TypeStructure

    TypeCategory* {.pure .} = enum ## Whether a type structure is classified as a single value, a vector or a matrix
        Primitive,
        Vector,
        Matrix,
        Other

proc `$`*(self: TypeStructure): string =
    ## Convert a type structure to a string
    result =
        case self.kind
        of TypeKind.Primitive: $self.dataType
        of TypeKind.Array: "Array[" & $self.count & ", " & $self.nested & "]"

proc `$`*(self: TypeField): string =
    ## Convert a type field to a string
    result = self.name & ": " & $self.structure

proc size*(dataType: OglType): int =
    ## Returns the size of an attribute data type
    case dataType
    of OglType.ByteType: sizeof(GLbyte)
    of OglType.UnsignedByteType: sizeof(GLubyte)
    of OglType.ShortType: sizeof(GLshort)
    of OglType.UnsignedShortType: sizeof(GLushort)
    of OglType.IntType: sizeof(GLint)
    of OglType.FloatType: sizeof(GLfloat)
    of OglType.DoubleType: sizeof(GLdouble)

proc asType*(typename: NimNode): OglType =
    ## Converts a type declaration to an OglType
    case typename.strVal.toLowerAscii
    of "glbyte": OglType.ByteType
    of "glubyte": OglType.UnsignedByteType
    of "glshort": OglType.ShortType
    of "glushort": OglType.UnsignedShortType
    of "glint": OglType.IntType
    of "glfloat": OglType.FloatType
    of "gldouble": OglType.DoubleType
    else:
        error(
            "Could not determine vertex attribute type for: " & typename.strVal &
            " (Make sure you're using the GL types, for example GLint or GLfloat)",
            typename
        )
        low(OglType)

proc getRangeSize*(range: NimNode): BiggestInt =
    ## Given a range node (0..2, for example), return how big it is
    expectKind range, nnkInfix
    assert(range[0].strVal == "..")
    expectKind range[1], nnkIntLit
    expectKind range[2], nnkIntLit
    result = range[2].intVal - range[1].intVal + 1

proc disect*(typename: NimNode): TypeStructure =
    ## Given type information, returns the number of fields as well as their type

    # This will de-obfuscate the GL type aliases back to arrays
    let dealiased = typename.getTypeImpl

    # If we are dealing with an array, recurse into the values it contains
    return if dealiased.kind == nnkBracketExpr:
        expectKind dealiased[0], nnkSym
        assert(dealiased[0].strVal == "array")
        TypeStructure(kind: TypeKind.Array, count: dealiased[1].getRangeSize, nested: dealiased[2].disect)
    else:
        TypeStructure(kind: TypeKind.Primitive, dataType: typename.asType)

proc fields*(struct: NimNode): seq[TypeField] =
    ## Creates code for generating TypeFields from a type
    for field, typeinfo in objFields(struct):
        result.add(TypeField(name: field, structure: typeinfo.disect))

proc totalCount*(structure: TypeStructure): BiggestInt =
    ## Returns the total count of values in a type structure
    case structure.kind:
    of TypeKind.Primitive: BiggestInt(1)
    of TypeKind.Array: structure.count * structure.nested.totalCount

proc coreType*(structure: TypeStructure): OglType =
    ## Returns the core type represented by a type structure
    case structure.kind:
    of TypeKind.Primitive: structure.dataType
    of TypeKind.Array: structure.nested.coreType

proc category*(structure: TypeStructure): TypeCategory =
    ## Returns the category of value described by a structure
    case structure.kind:
    of TypeKind.Primitive:
        TypeCategory.Primitive
    of TypeKind.Array:
        case structure.nested.category:
        of TypeCategory.Primitive: TypeCategory.Vector
        of TypeCategory.Vector: TypeCategory.Matrix
        of TypeCategory.Matrix, TypeCategory.Other: TypeCategory.Other


