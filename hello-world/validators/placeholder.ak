use cardano/address.{Credential}
use cardano/assets.{PolicyId}
use cardano/certificate.{Certificate}
use cardano/governance.{ProposalProcedure, Voter}
use cardano/transaction.{Transaction, OutputReference}

use aiken/primitive/string
use cardano/transaction.{OutputReference, Transaction}

pub type Redeemer {
msg: ByteArray,
}

validator alwayssuccess {
spend(
_datum: Option<Data>,
redeemer: Redeemer,
_utxo: OutputReference,
_self: Transaction,
) {
// ctx: ScriptContext,
trace @"redeemer": string.from_bytearray(redeemer.msg)
let a = True
a?
}

else(_) {
fail
}
}
  // // If needs be, remove any of unneeded handlers above, and use:
  //
  // else(_ctx: ScriptContext) {
  //   todo @"fallback logic if none of the other purposes match"
  // }
  //
  // // You will also need an additional import:
  // //
  // // use cardano/script_context.{ScriptContext}

