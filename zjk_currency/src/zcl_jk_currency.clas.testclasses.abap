"! Test double for the decimals source. It answers with a fixed number of
"! decimal places and records the currency it was asked about, so a test can
"! prove the converter passes the currency on rather than assuming one.
CLASS lcl_decimals DEFINITION.

  PUBLIC SECTION.

    INTERFACES zif_jk_currency_decimals.

    METHODS constructor
      IMPORTING
        decimals TYPE i.

    METHODS asked_about
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    DATA decimals TYPE i.
    DATA last_currency TYPE string.

ENDCLASS.


CLASS lcl_decimals IMPLEMENTATION.

  METHOD constructor.

    me->decimals = decimals.

  ENDMETHOD.


  METHOD asked_about.

    result = last_currency.

  ENDMETHOD.


  METHOD zif_jk_currency_decimals~get_decimals.

    last_currency = currency.
    result = me->decimals.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_to_external DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS scales_up_a_zero_decimal FOR TESTING.
    METHODS leaves_an_ordinary_currency FOR TESTING.
    METHODS scales_down_a_three_decimal FOR TESTING.
    METHODS keeps_a_negative_amount FOR TESTING.
    METHODS leaves_zero_at_zero FOR TESTING.
    METHODS passes_currency_to_source FOR TESTING.
    METHODS rounds_beyond_four_decimals FOR TESTING.

    METHODS converter
      IMPORTING
        decimals      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO zcl_jk_currency.
ENDCLASS.


CLASS ltcl_to_external IMPLEMENTATION.

  METHOD converter.

    result = zcl_jk_currency=>create( NEW lcl_decimals( decimals ) ).

  ENDMETHOD.


  METHOD scales_up_a_zero_decimal.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '10.00'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '1000'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 0 )->to_external( amount   = stored
                                         currency = `JPY` )
      msg = 'A currency without decimals is stored one hundredth of its amount' ).

  ENDMETHOD.


  METHOD leaves_an_ordinary_currency.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '1234.56'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '1234.56'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 2 )->to_external( amount   = stored
                                         currency = `EUR` ) ).

  ENDMETHOD.


  METHOD scales_down_a_three_decimal.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '12.34'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '1.234'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 3 )->to_external( amount   = stored
                                         currency = `TND` )
      msg = 'A third decimal is held one place to the left in a CURR field' ).

  ENDMETHOD.


  METHOD keeps_a_negative_amount.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '-10.00'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '-1000'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 0 )->to_external( amount   = stored
                                         currency = `JPY` ) ).

  ENDMETHOD.


  METHOD leaves_zero_at_zero.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '0'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '0'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 0 )->to_external( amount   = stored
                                         currency = `JPY` ) ).

  ENDMETHOD.


  METHOD passes_currency_to_source.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '10.00'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '1000'.
    DATA(source) = NEW lcl_decimals( 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = zcl_jk_currency=>create( source )->to_external( amount   = stored
                                                           currency = `JPY` ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = `JPY`
      act = source->asked_about( )
      msg = 'The currency has to reach the source, not be assumed' ).

  ENDMETHOD.


  METHOD rounds_beyond_four_decimals.

    DATA stored TYPE zcl_jk_currency=>internal_amount VALUE '12.34'.
    DATA expected TYPE zcl_jk_currency=>external_amount VALUE '0.0123'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 5 )->to_external( amount   = stored
                                         currency = `XXX` )
      msg = 'Four decimals are a ceiling: 0.01234 is rounded, not rejected' ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_to_internal DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS scales_down_a_zero_decimal FOR TESTING.
    METHODS leaves_an_ordinary_currency FOR TESTING.
    METHODS scales_up_a_three_decimal FOR TESTING.
    METHODS round_trip_is_stable FOR TESTING.
    METHODS rounds_a_fractional_amount FOR TESTING.

    METHODS converter
      IMPORTING
        decimals      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO zcl_jk_currency.
ENDCLASS.


CLASS ltcl_to_internal IMPLEMENTATION.

  METHOD converter.

    result = zcl_jk_currency=>create( NEW lcl_decimals( decimals ) ).

  ENDMETHOD.


  METHOD scales_down_a_zero_decimal.

    DATA amount TYPE zcl_jk_currency=>external_amount VALUE '1000'.
    DATA expected TYPE zcl_jk_currency=>internal_amount VALUE '10.00'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 0 )->to_internal( amount   = amount
                                         currency = `JPY` ) ).

  ENDMETHOD.


  METHOD leaves_an_ordinary_currency.

    DATA amount TYPE zcl_jk_currency=>external_amount VALUE '1234.56'.
    DATA expected TYPE zcl_jk_currency=>internal_amount VALUE '1234.56'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 2 )->to_internal( amount   = amount
                                         currency = `EUR` ) ).

  ENDMETHOD.


  METHOD scales_up_a_three_decimal.

    DATA amount TYPE zcl_jk_currency=>external_amount VALUE '1.234'.
    DATA expected TYPE zcl_jk_currency=>internal_amount VALUE '12.34'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 3 )->to_internal( amount   = amount
                                         currency = `TND` ) ).

  ENDMETHOD.


  METHOD round_trip_is_stable.

    DATA original TYPE zcl_jk_currency=>external_amount VALUE '1000'.

    DATA(subject) = converter( 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = original
      act = subject->to_external( amount   = subject->to_internal( amount   = original
                                                                  currency = `JPY` )
                                  currency = `JPY` ) ).

  ENDMETHOD.


  METHOD rounds_a_fractional_amount.

    DATA amount TYPE zcl_jk_currency=>external_amount VALUE '1000.5'.
    DATA expected TYPE zcl_jk_currency=>internal_amount VALUE '10.01'.

    cl_abap_unit_assert=>assert_equals(
      exp = expected
      act = converter( 0 )->to_internal( amount   = amount
                                         currency = `JPY` )
      msg = 'JPY should never carry a fraction, but half is rounded up if it does' ).

  ENDMETHOD.

ENDCLASS.
