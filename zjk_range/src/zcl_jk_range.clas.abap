"! <p class="shorttext synchronized">Select-options range evaluation</p>
"! Evaluates a selection table the way the ABAP <em>IN</em> operator does.
"! The rules are documented but rarely known in full: an empty selection
"! matches everything, an exclusion always beats an inclusion, and a selection
"! holding only exclusions matches everything it does not exclude.
"!
"! Comparison is character based, which is what a selection over a CHAR, NUMC
"! or DATS field does. A selection over a numeric field orders differently.
CLASS zcl_jk_range DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    "! A selection table, as a SELECT-OPTIONS statement builds one
    TYPES range_table TYPE RANGE OF string.

    CONSTANTS include TYPE c LENGTH 1 VALUE 'I' ##NO_TEXT.
    CONSTANTS exclude TYPE c LENGTH 1 VALUE 'E' ##NO_TEXT.

    "! Whether a value satisfies a selection table.
    "! @parameter value     | the value under test
    "! @parameter selection | the selection table, possibly empty
    "! @parameter result    | true when the value is selected
    CLASS-METHODS matches
      IMPORTING
        value         TYPE string
        selection     TYPE range_table
      RETURNING
        VALUE(result) TYPE abap_bool.

  PRIVATE SECTION.

    "! Whether a value satisfies one row, ignoring its sign
    CLASS-METHODS satisfies
      IMPORTING
        value         TYPE string
        row           TYPE LINE OF range_table
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS zcl_jk_range IMPLEMENTATION.

  METHOD matches.

    DATA has_include TYPE abap_bool.
    DATA matches_include TYPE abap_bool.

    IF selection IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    LOOP AT selection INTO DATA(row).

      CASE row-sign.

        WHEN exclude.
          IF satisfies( value = value
                        row   = row ) = abap_true.
            result = abap_false.
            RETURN.
          ENDIF.

        WHEN include.
          has_include = abap_true.
          IF satisfies( value = value
                        row   = row ) = abap_true.
            matches_include = abap_true.
          ENDIF.

        WHEN OTHERS.
          " A row that is neither included nor excluded states nothing.

      ENDCASE.

    ENDLOOP.

    result = xsdbool( has_include = abap_false OR matches_include = abap_true ).

  ENDMETHOD.


  METHOD satisfies.

    CASE row-option.

      WHEN 'EQ'.
        result = xsdbool( value = row-low ).

      WHEN 'NE'.
        result = xsdbool( value <> row-low ).

      WHEN 'GT'.
        result = xsdbool( value > row-low ).

      WHEN 'GE'.
        result = xsdbool( value >= row-low ).

      WHEN 'LT'.
        result = xsdbool( value < row-low ).

      WHEN 'LE'.
        result = xsdbool( value <= row-low ).

      WHEN 'BT'.
        result = xsdbool( value >= row-low AND value <= row-high ).

      WHEN 'NB'.
        result = xsdbool( NOT ( value >= row-low AND value <= row-high ) ).

      WHEN 'CP'.
        result = xsdbool( value CP row-low ).

      WHEN 'NP'.
        result = xsdbool( value NP row-low ).

      WHEN OTHERS.
        result = abap_false.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
