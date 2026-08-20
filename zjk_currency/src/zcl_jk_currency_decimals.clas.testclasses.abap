CLASS ltcl_get_decimals DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS reads_a_zero_decimal_currency FOR TESTING.
    METHODS reads_a_three_decimal_currency FOR TESTING.
    METHODS absent_currency_uses_two FOR TESTING.
    METHODS defaults_when_tcurx_is_empty FOR TESTING.

    METHODS tcurx
      RETURNING
        VALUE(result) TYPE zcl_jk_currency_decimals=>tcurx_table.
ENDCLASS.


CLASS ltcl_get_decimals IMPLEMENTATION.

  METHOD tcurx.

    result = VALUE #( ( currency = `JPY` decimals = 0 )
                      ( currency = `TND` decimals = 3 ) ).

  ENDMETHOD.


  METHOD reads_a_zero_decimal_currency.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = zcl_jk_currency_decimals=>create( tcurx( ) )->get_decimals( `JPY` ) ).

  ENDMETHOD.


  METHOD reads_a_three_decimal_currency.

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = zcl_jk_currency_decimals=>create( tcurx( ) )->get_decimals( `TND` ) ).

  ENDMETHOD.


  METHOD absent_currency_uses_two.

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = zcl_jk_currency_decimals=>create( tcurx( ) )->get_decimals( `PLN` )
      msg = 'TCURX only lists deviations, so an absent currency uses two' ).

  ENDMETHOD.


  METHOD defaults_when_tcurx_is_empty.

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = zcl_jk_currency_decimals=>create( )->get_decimals( `EUR` ) ).

  ENDMETHOD.

ENDCLASS.
