import { Blockfrost, Lucid, Crypto, fromText, Data, Addresses } from "https://deno.land/x/lucid/mod.ts";//Import các thư viện cần thiết từ Lucid

// Provider selection
// deno run  --allow-all lucid_btap.ts //Lenh terminal
// There are multiple builtin providers you can choose from in Lucid.

// Blockfrost

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewYEl8tbwHxBsBXqHhcknhF9if4hHBnWuU",
  ),
});// //Khởi tạo Lucid với provider là Blockfrost


//Câu 1
const seed = "later face fever client gaze rain fiscal myself chicken core either afraid leave view hotel razor type famous more chaos ghost muffin task vintage" //Seed của ví
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0 });//Chọn ví từ seed


const address = await lucid.wallet.address(); // Bech32 address
console.log (`Đ/c ví gửi: ${address}`) //Hiện thị địa chỉ ví hiện tại


//Câu 2
const utxos = await lucid.wallet.getUtxos();//Lấy toàn bộ UTxOs của ví
const totalLovelace = utxos.reduce((acc, utxo) => acc + BigInt(utxo.assets["lovelace"] ?? 0n), 0n);//Tính tổng số Lovelace trong tất cả UTxOs
const ada = Number(totalLovelace) / 1_000_000; // Chuyển đổi từ Lovelace sang ADA
console.log(`Số dư ví: ${ada.toFixed(6)} ADA`);//Hiện thị số dư ví


//Câu 3
//=================Tạo minting script=========================
async function createMintingscripts(slot_in: bigint) {
  const { payment } = Addresses.inspect(await lucid.wallet.address());

  const mintingScripts = lucid.newScript({
    type: "All",
    scripts: [
      { type: "Sig", keyHash: payment.hash },
      { type: "Before", slot: slot_in },
    ],
  });

  return mintingScripts;
}

//=================mintToken=============================================
async function mintToken(policyId: string, tokenName: string, amount: bigint, slot_in: bigint) {
  const unit = policyId + fromText(tokenName);

//=================Tạo tx mint token=========================
const tx = await lucid.newTx()
.mint({ [unit]: amount })//Mint token
.validTo(Date.now() + 400000)//Thời gian hết hạn của tx
.attachScript(await createMintingscripts(slot_in))//Gán minting script vào tx
.commit();//Chạy tx

return tx;//Trả về tx đã chạy
}


//=================Chạy hàm mintToken=========================
const slot_in = BigInt(85885593)//Thời gian hết hạn của tx
console.log(`Slot: ${slot_in}`);

const mintingScripts = await createMintingscripts(slot_in);//Chạy hàm tạo minting script

const policyId = mintingScripts.toHash(); //Lấy mã chính sách minting
console.log(`Mã chính sách minting là: ${policyId}`);

const tx = await mintToken(policyId, "BK03:393", 500n, slot_in);//Chạy hàm mintToken

let signedtx = await tx.sign().commit();//Chạy tx đã ký
let txHashToken = await signedtx.submit();//Gửi tx đã ký 
console.log(`Bạn có thể kiểm tra giao dịch tại: https://preview.cexplorer.io/tx/${txHashToken}`); 


Câu 4
//Khởi tạo script luôn thành công từ mã Plutuss
const alwaysSucceed_scripts = lucid.newScript({
  type: "PlutusV3",
  script: "58af01010029800aba2aba1aab9faab9eaab9dab9a48888896600264653001300700198039804000cc01c0092225980099b8748008c01cdd500144c8cc896600266e1d2000300a375400d13232598009808001456600266e1d2000300c375400713371e6eb8c03cc034dd5180798069baa003375c601e601a6ea80222c805a2c8070dd7180700098059baa0068b2012300b001300b300c0013008375400516401830070013003375400f149a26cac80081",
});

const alwaysSucceedAddress = alwaysSucceed_scripts.toAddress();//Chuyển đổi mã Plutus thành địa chỉ
console.log(`Always succeed address: ${alwaysSucceedAddress}`);


//=================Tạo Datum=========================
const DatumSchema = Data.Object({
  msg: Data.Bytes, // msg là một ByteArray
  });
  // Định nghĩa cấu trúc Redeemer
  const RedeemerSchema = Data.Object({
  msg: Data.Bytes, // msg là một ByteArray
  });
  
  // Tạo một Datum với giá trị cụ thể
  const Datum = () => Data.to({ msg: fromText("Dinh Hoang Ha_393") }, DatumSchema); // "48656c6c6f20576f726c64" là chuỗi "Hello World" được mã hóa dưới dạng hex
  console.log("Datum: ", Datum());

  // Tạo một Redeemer với giá trị cụ thể
  const Redeemer = () => Data.to({ msg: fromText("Dinh Hoang Ha_393") }, RedeemerSchema); // "48656c6c6f20576f726c64" là chuỗi "Hello World" được mã hóa dưới dạng hex
  const lovelace_lock=50_393_393n
  console.log(`Lovelace lock: ${lovelace_lock}`);



//Câu 5
//=================Lock UTxO=========================
export async function lockUtxo(lovelace: bigint, tokenAmount: bigint, policyId: string): Promise<string> {
  const unit = policyId + fromText("BK03:393");
  const tx = await lucid
  .newTx()
  .payToContract(alwaysSucceedAddress, { Inline: Datum() }, { lovelace, [unit]: tokenAmount })//Gửi UTxO đến địa chỉ luôn thành công
  .commit();
  
  const signedTx = await tx.sign().commit();
  console.log(signedTx);
  
  const txHash = await signedTx.submit();
  
  return txHash;
}


//Câu 6
//=================Unlock UTxO=========================
export async function unlockUtxo(redeemer: RedeemerSchema ): Promise<string> {

  const utxo = (await lucid.utxosAt(alwaysSucceedAddress)).find((utxo) => 
  !utxo.scriptRef && utxo.datum === redeemer // && utxo.assets.lovelace == lovelace
  );
  console.log(`redeemer: ${redeemer}`);
  console.log(`UTxO unlock: ${utxo}`);
  
  console.log(utxo);
  if (!utxo) throw new Error("No UTxO with found");
  const tx = await lucid
  .newTx()
  .collectFrom([utxo], Redeemer())
  .attachScript(alwaysSucceed_scripts)
  .commit();
  
  const signedTx = await tx.sign().commit();
  
  const txHash = await signedTx.submit();
  
  return txHash;
}


//=================Chạy hàm lockUtxo=========================
const txHash = await lockUtxo(lovelace_lock, 500n, "4105f010e794cdb8ff7984e4694df9a1db174c4d825cea81a3481632");//Mã policyId cua token la: "4105f010e794cdb8ff7984e4694df9a1db174c4d825cea81a3481632"
console.log(`Transaction hash: ${txHash}`);


//=================Chạy hàm unlockUtxo=========================
const redeemTxHash = await unlockUtxo(Redeemer());
console.log(`Transaction hash: ${redeemTxHash}`);
