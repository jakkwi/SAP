CLASS ltcl_to_internal DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS pads_number_to_default_length FOR TESTING.
    METHODS pads_number_to_given_length FOR TESTING.
    METHODS keeps_value_of_exact_length FOR TESTING.
    METHODS keeps_too_long_value FOR TESTING.
    METHODS keeps_non_numeric_value FOR TESTING.
    METHODS keeps_initial_value FOR TESTING.
    METHODS ignores_surrounding_blanks FOR TESTING.
ENDCLASS.


CLASS ltcl_to_internal IMPLEMENTATION.

  METHOD pads_number_to_default_length.
    cl_abap_unit_assert=>assert_equals(
      exp = `000000000000004711`
      act = zcl_jk_alpha=>to_internal( `4711` )
      msg = 'Numeric input should be padded to 18 characters' ).
  ENDMETHOD.

  METHOD pads_number_to_given_length.
    cl_abap_unit_assert=>assert_equals(
      exp = `0000004711`
      act = zcl_jk_alpha=>to_internal( input  = `4711`
                                       length = 10 )
      msg = 'Explicit length should override the default' ).
  ENDMETHOD.

  METHOD keeps_value_of_exact_length.
    cl_abap_unit_assert=>assert_equals(
      exp = `4711`
      act = zcl_jk_alpha=>to_internal( input  = `4711`
                                       length = 4 ) ).
  ENDMETHOD.

  METHOD keeps_too_long_value.
    cl_abap_unit_assert=>assert_equals(
      exp = `4711`
      act = zcl_jk_alpha=>to_internal( input  = `4711`
                                       length = 3 )
      msg = 'Values longer than the target length must not be truncated' ).
  ENDMETHOD.

  METHOD keeps_non_numeric_value.
    cl_abap_unit_assert=>assert_equals(
      exp = `MAT-001`
      act = zcl_jk_alpha=>to_internal( `MAT-001` )
      msg = 'Non numeric input must stay untouched' ).
  ENDMETHOD.

  METHOD keeps_initial_value.
    cl_abap_unit_assert=>assert_equals(
      exp = ``
      act = zcl_jk_alpha=>to_internal( `` ) ).
  ENDMETHOD.

  METHOD ignores_surrounding_blanks.
    cl_abap_unit_assert=>assert_equals(
      exp = `000000000000004711`
      act = zcl_jk_alpha=>to_internal( `  4711  ` ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_to_external DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS removes_leading_zeros FOR TESTING.
    METHODS keeps_single_zero FOR TESTING.
    METHODS keeps_non_numeric_value FOR TESTING.
    METHODS round_trip_is_stable FOR TESTING.
ENDCLASS.


CLASS ltcl_to_external IMPLEMENTATION.

  METHOD removes_leading_zeros.
    cl_abap_unit_assert=>assert_equals(
      exp = `4711`
      act = zcl_jk_alpha=>to_external( `000000000000004711` ) ).
  ENDMETHOD.

  METHOD keeps_single_zero.
    cl_abap_unit_assert=>assert_equals(
      exp = `0`
      act = zcl_jk_alpha=>to_external( `000000000000000000` )
      msg = 'An all zero value must not collapse into an empty string' ).
  ENDMETHOD.

  METHOD keeps_non_numeric_value.
    cl_abap_unit_assert=>assert_equals(
      exp = `00MAT-001`
      act = zcl_jk_alpha=>to_external( `00MAT-001` ) ).
  ENDMETHOD.

  METHOD round_trip_is_stable.
    DATA(original) = `4711`.

    cl_abap_unit_assert=>assert_equals(
      exp = original
      act = zcl_jk_alpha=>to_external( zcl_jk_alpha=>to_internal( original ) ) ).
  ENDMETHOD.

ENDCLASS.
