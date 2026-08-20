"! <p class="shorttext synchronized">Decimal places from an in memory TCURX</p>
"! Holds the TCURX exceptions in memory. The caller selects them once, at the
"! edge of the application, and everything below stays free of database access.
"! TCURX only lists currencies that deviate from two decimal places, so an
"! entry that is absent is not an error - it means the ordinary two.
CLASS zcl_jk_currency_decimals DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    INTERFACES zif_jk_currency_decimals.

    TYPES:
      "! One TCURX row: a currency that does not use two decimal places
      BEGIN OF tcurx_entry,
        currency TYPE string,
        decimals TYPE i,
      END OF tcurx_entry,
      tcurx_table TYPE SORTED TABLE OF tcurx_entry WITH UNIQUE KEY currency.

    "! Decimal places used by every currency that TCURX does not mention
    CONSTANTS default_decimals TYPE i VALUE 2 ##NO_TEXT.

    "! @parameter tcurx  | the deviating currencies, read from the database once
    "! @parameter result | a decimals source ready to be handed to the converter
    CLASS-METHODS create
      IMPORTING
        tcurx         TYPE tcurx_table OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO zif_jk_currency_decimals.

    METHODS constructor
      IMPORTING
        tcurx TYPE tcurx_table.

  PRIVATE SECTION.

    DATA entries TYPE tcurx_table.

ENDCLASS.


CLASS zcl_jk_currency_decimals IMPLEMENTATION.

  METHOD create.

    result = NEW zcl_jk_currency_decimals( tcurx ).

  ENDMETHOD.


  METHOD constructor.

    entries = tcurx.

  ENDMETHOD.


  METHOD zif_jk_currency_decimals~get_decimals.

    result = VALUE #( entries[ currency = currency ]-decimals
                      DEFAULT default_decimals ).

  ENDMETHOD.

ENDCLASS.
