CLASS ltcl_signs DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS empty_selection_matches_all FOR TESTING.
    METHODS include_matches_its_value FOR TESTING.
    METHODS include_rejects_other_value FOR TESTING.
    METHODS exclusion_beats_inclusion FOR TESTING.
    METHODS exclusion_wins_whatever_order FOR TESTING.
    METHODS only_exclusions_match_rest FOR TESTING.
    METHODS only_exclusions_reject_a_hit FOR TESTING.
ENDCLASS.


CLASS ltcl_signs IMPLEMENTATION.

  METHOD empty_selection_matches_all.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_jk_range=>matches( value     = `ANYTHING`
                                   selection = VALUE #( ) )
      msg = 'An unfilled select-option restricts nothing, it does not exclude everything' ).

  ENDMETHOD.


  METHOD include_matches_its_value.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_jk_range=>matches( value     = `ALPHA`
                                   selection = VALUE #( ( sign = 'I' option = 'EQ' low = `ALPHA` ) ) ) ).

  ENDMETHOD.


  METHOD include_rejects_other_value.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_jk_range=>matches( value     = `BETA`
                                   selection = VALUE #( ( sign = 'I' option = 'EQ' low = `ALPHA` ) ) ) ).

  ENDMETHOD.


  METHOD exclusion_beats_inclusion.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_jk_range=>matches( value     = `ALPHA`
                                   selection = VALUE #( ( sign = 'I' option = 'EQ' low = `ALPHA` )
                                                        ( sign = 'E' option = 'EQ' low = `ALPHA` ) ) )
      msg = 'A value that is both included and excluded is excluded' ).

  ENDMETHOD.


  METHOD exclusion_wins_whatever_order.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_jk_range=>matches( value     = `ALPHA`
                                   selection = VALUE #( ( sign = 'E' option = 'EQ' low = `ALPHA` )
                                                        ( sign = 'I' option = 'EQ' low = `ALPHA` ) ) )
      msg = 'Row order must not decide the outcome' ).

  ENDMETHOD.


  METHOD only_exclusions_match_rest.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_jk_range=>matches( value     = `ALPHA`
                                   selection = VALUE #( ( sign = 'E' option = 'EQ' low = `BETA` ) ) )
      msg = 'A selection holding only exclusions selects everything it does not exclude' ).

  ENDMETHOD.


  METHOD only_exclusions_reject_a_hit.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_jk_range=>matches( value     = `BETA`
                                   selection = VALUE #( ( sign = 'E' option = 'EQ' low = `BETA` ) ) ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_options DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS eq_matches_the_value FOR TESTING.
    METHODS ne_matches_anything_else FOR TESTING.
    METHODS gt_is_strict FOR TESTING.
    METHODS ge_includes_the_bound FOR TESTING.
    METHODS lt_is_strict FOR TESTING.
    METHODS le_includes_the_bound FOR TESTING.
    METHODS bt_includes_both_bounds FOR TESTING.
    METHODS nb_excludes_the_span FOR TESTING.
    METHODS cp_matches_a_pattern FOR TESTING.
    METHODS np_rejects_a_pattern FOR TESTING.

    METHODS selected
      IMPORTING
        value         TYPE string
        option        TYPE string
        low           TYPE string
        high          TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS ltcl_options IMPLEMENTATION.

  METHOD selected.

    result = zcl_jk_range=>matches(
               value     = value
               selection = VALUE #( ( sign = 'I' option = option low = low high = high ) ) ).

  ENDMETHOD.


  METHOD eq_matches_the_value.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `M` option = `EQ` low = `M` ) ).

  ENDMETHOD.


  METHOD ne_matches_anything_else.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `A` option = `NE` low = `M` ) ).

  ENDMETHOD.


  METHOD gt_is_strict.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `M` option = `GT` low = `M` )
      msg = 'Greater than must not accept the bound itself' ).

  ENDMETHOD.


  METHOD ge_includes_the_bound.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `M` option = `GE` low = `M` ) ).

  ENDMETHOD.


  METHOD lt_is_strict.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `M` option = `LT` low = `M` ) ).

  ENDMETHOD.


  METHOD le_includes_the_bound.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `M` option = `LE` low = `M` ) ).

  ENDMETHOD.


  METHOD bt_includes_both_bounds.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `A` option = `BT` low = `A` high = `M` )
      msg = 'Between is inclusive at both ends' ).

  ENDMETHOD.


  METHOD nb_excludes_the_span.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `C` option = `NB` low = `A` high = `M` ) ).

  ENDMETHOD.


  METHOD cp_matches_a_pattern.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `MAT-4711` option = `CP` low = `MAT-*` ) ).

  ENDMETHOD.


  METHOD np_rejects_a_pattern.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `MAT-4711` option = `NP` low = `DOC-*` ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_edges DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS bt_with_reversed_bounds FOR TESTING.
    METHODS unknown_option_never_matches FOR TESTING.
    METHODS compares_as_characters FOR TESTING.
    METHODS cp_ignores_case FOR TESTING.

    METHODS selected
      IMPORTING
        value         TYPE string
        option        TYPE string
        low           TYPE string
        high          TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS ltcl_edges IMPLEMENTATION.

  METHOD selected.

    result = zcl_jk_range=>matches(
               value     = value
               selection = VALUE #( ( sign = 'I' option = option low = low high = high ) ) ).

  ENDMETHOD.


  METHOD bt_with_reversed_bounds.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `C` option = `BT` low = `M` high = `A` )
      msg = 'A span whose bounds are the wrong way round holds nothing' ).

  ENDMETHOD.


  METHOD unknown_option_never_matches.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `ALPHA` option = `XX` low = `ALPHA` )
      msg = 'An option that is not one of the ten selects nothing' ).

  ENDMETHOD.


  METHOD compares_as_characters.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = selected( value = `15` option = `BT` low = `9` high = `20` )
      msg = 'Character order, not numeric order: 15 sorts before 9' ).

  ENDMETHOD.


  METHOD cp_ignores_case.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = selected( value = `mat-4711` option = `CP` low = `MAT-*` )
      msg = 'CP and NP disregard case, unlike the other comparisons' ).

  ENDMETHOD.

ENDCLASS.
