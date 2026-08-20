"! <p class="shorttext synchronized">Currency amounts between storage and display</p>
"! A CURR field always carries two decimal places, whatever the currency does.
"! For a currency that uses a different number, SAP shifts the amount before it
"! reaches the database, so the stored digits and the real amount differ by a
"! power of ten. This class performs that shift in both directions.
"!
"! The number of decimal places comes from a <em>zif_jk_currency_decimals</em>
"! supplied at construction time, which keeps the arithmetic testable.
CLASS zcl_jk_currency DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    "! Amount as stored in a CURR field: always two decimal places
    TYPES internal_amount TYPE p LENGTH 15 DECIMALS 2.
    "! Amount as a person reads it, mirroring BAPICURR with four decimal places
    TYPES external_amount TYPE p LENGTH 15 DECIMALS 4.

    "! Decimal places of a CURR field, regardless of the currency
    CONSTANTS internal_decimals TYPE i VALUE 2 ##NO_TEXT.

    "! @parameter decimals | where the decimal places of a currency come from
    "! @parameter result   | a converter bound to that source
    CLASS-METHODS create
      IMPORTING
        decimals      TYPE REF TO zif_jk_currency_decimals
      RETURNING
        VALUE(result) TYPE REF TO zcl_jk_currency.

    "! Converts a stored amount into the amount a person reads.
    "! @parameter amount   | amount as held in a CURR field
    "! @parameter currency | ISO currency code, for example JPY
    "! @parameter result   | amount in its real magnitude
    METHODS to_external
      IMPORTING
        amount        TYPE internal_amount
        currency      TYPE string
      RETURNING
        VALUE(result) TYPE external_amount.

    "! Converts a real amount into the value a CURR field has to hold.
    "! @parameter amount   | amount in its real magnitude
    "! @parameter currency | ISO currency code, for example JPY
    "! @parameter result   | amount as it belongs in a CURR field
    METHODS to_internal
      IMPORTING
        amount        TYPE external_amount
        currency      TYPE string
      RETURNING
        VALUE(result) TYPE internal_amount.

    METHODS constructor
      IMPORTING
        decimals TYPE REF TO zif_jk_currency_decimals.

  PRIVATE SECTION.

    DATA decimals_source TYPE REF TO zif_jk_currency_decimals.

    CLASS-METHODS power_of_ten
      IMPORTING
        exponent      TYPE i
      RETURNING
        VALUE(result) TYPE i.

ENDCLASS.


CLASS zcl_jk_currency IMPLEMENTATION.

  METHOD create.

    result = NEW zcl_jk_currency( decimals ).

  ENDMETHOD.


  METHOD constructor.

    decimals_source = decimals.

  ENDMETHOD.


  METHOD to_external.

    DATA(places) = decimals_source->get_decimals( currency ).

    IF places <= internal_decimals.
      result = amount * power_of_ten( internal_decimals - places ).
    ELSE.
      result = amount / power_of_ten( places - internal_decimals ).
    ENDIF.

  ENDMETHOD.


  METHOD to_internal.

    DATA(places) = decimals_source->get_decimals( currency ).

    IF places <= internal_decimals.
      result = amount / power_of_ten( internal_decimals - places ).
    ELSE.
      result = amount * power_of_ten( places - internal_decimals ).
    ENDIF.

  ENDMETHOD.


  METHOD power_of_ten.

    result = 1.

    DO exponent TIMES.
      result = result * 10.
    ENDDO.

  ENDMETHOD.

ENDCLASS.
