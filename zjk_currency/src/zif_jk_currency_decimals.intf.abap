"! <p class="shorttext synchronized">Decimal places used by a currency</p>
"! The number of decimal places a currency uses lives in TCURX, a database
"! table. Conversion logic that reads it directly cannot be unit tested, so it
"! is abstracted behind this interface and supplied from the outside.
INTERFACE zif_jk_currency_decimals
  PUBLIC.

  "! Decimal places used by a currency.
  "! @parameter currency | ISO currency code, for example JPY
  "! @parameter result   | decimal places, two for an ordinary currency
  METHODS get_decimals
    IMPORTING
      currency      TYPE string
    RETURNING
      VALUE(result) TYPE i.

ENDINTERFACE.
