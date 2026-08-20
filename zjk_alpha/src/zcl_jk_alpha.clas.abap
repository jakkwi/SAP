"! <p class="shorttext synchronized">ALPHA conversion without conversion exits</p>
"! Pure ABAP re-implementation of the ALPHA conversion routine.
"! Free of database access and function modules, so it can be unit tested
"! anywhere - including outside an SAP system via the abaplint transpiler.
CLASS zcl_jk_alpha DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CONSTANTS default_length TYPE i VALUE 18 ##NO_TEXT.

    "! Converts a value to its internal representation (leading zeros).
    "! Non numeric input and input exceeding <em>length</em> is returned unchanged,
    "! which mirrors the behaviour of CONVERSION_EXIT_ALPHA_INPUT.
    "! @parameter input  | value in external format
    "! @parameter length | target length, defaults to 18
    "! @parameter result | value in internal format
    CLASS-METHODS to_internal
      IMPORTING
        input         TYPE string
        length        TYPE i DEFAULT default_length
      RETURNING
        VALUE(result) TYPE string.

    "! Converts a value to its external representation (leading zeros removed).
    "! @parameter input  | value in internal format
    "! @parameter result | value in external format
    CLASS-METHODS to_external
      IMPORTING
        input         TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    CLASS-METHODS is_numeric
      IMPORTING
        input         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS zcl_jk_alpha IMPLEMENTATION.

  METHOD to_internal.

    DATA(value) = condense( val = input ).

    IF is_numeric( value ) = abap_false OR strlen( value ) > length.
      result = value.
      RETURN.
    ENDIF.

    result = |{ value WIDTH = length PAD = '0' ALIGN = RIGHT }|.

  ENDMETHOD.


  METHOD to_external.

    DATA(value) = condense( val = input ).

    IF is_numeric( value ) = abap_false.
      result = value.
      RETURN.
    ENDIF.

    SHIFT value LEFT DELETING LEADING '0'.

    result = COND #( WHEN value IS INITIAL THEN `0` ELSE value ).

  ENDMETHOD.


  METHOD is_numeric.

    result = xsdbool( input IS NOT INITIAL AND input CO '0123456789' ).

  ENDMETHOD.

ENDCLASS.
