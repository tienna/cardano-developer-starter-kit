use aiken/primitive/string
use cardano/transaction.{OutputReference, Transaction}

pub type Datum {
  value: ByteArray,
}

pub type Redeemer {
  value: ByteArray,
}

validator compare_datum_redeemer {
  spend(
    datum: Option<Datum>,
    redeemer: Redeemer,
    _utxo: OutputReference,
    _self: Transaction,
  ) {
    expect Some(datum_input) = datum
    let d: Datum = datum_input

    trace @"redeemer": string.from_bytearray(redeemer.value)

    let is_equal = d.value == redeemer.value
    is_equal?
  }

  else(_) {
    fail
  }
}
