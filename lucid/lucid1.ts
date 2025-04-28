import { Blockfrost, Lucid, Crypto ,fromText,Data, Addresses, } from "https://deno.land/x/lucid/mod.ts";

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewjeV1C6kZZcdvOk8U2RS7DnGt5XwwvaWS"
  ),
}); 


const seed="receive company catalog screen erase shallow verb wool asthma bring north average side chunk bulk submit hip spend antique unaware purity right fat someone"
lucid.selectWalletFromSeed(seed,{addressType:"Base", index:0})

//const address = await lucid.wallet.address();
//console.log(`địa chỉ gửi: ${address}`)

//const utxos = await lucid.wallet.getUtxos();
//const utxo=utxos[1];
//console.log (utxo)
//console.log (utxos)

//console.log(lucid);

// Lấy thông tin assets từ UTxO
//const assets = utxo.assets;

// Hiển thị thông tin assets
// console.log("Assets:", assets);

// Hiển thị toàn bộ tài sản và giá trị của chúng
//for (const assetname in assets) {
// console.log(`Assetname: ${assetname}, Value: ${assets[assetname]}`);
//}
//const [scriptUtxo] = await lucid.utxosAt("addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw");
//console.log(scriptUtxo)
//const receiverAddress = "addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw";

//try {
  
  //const tx = await lucid.newTx()
    //.payTo(receiverAddress, { lovelace: 1_000_000n }) 
   // .commit();

  // 5. Ký và gửi
 // const signedTx = await tx.sign().commit();
 // const txHash = await signedTx.submit();

  //console.log("Giao dịch thành công!");
  //console.log("Tx Hash:", txHash);
  
//} catch (error) {
 // console.error(" Lỗi:", error);
//}
//async function createSendNativeTokens(
 // receiverAddress: string,
 // policyId: string,
 // assetName: string,
  //amount: bigint
//) {
  //try {
   // const assetId = policyId + fromText(assetName);
    
    // 👇 Sử dụng .commit() thay vì .complete()
    //const tx = await lucid.newTx()
     // .payTo(receiverAddress, { 
     //   [assetId]: amount,
     //   lovelace: 2_000_000n // Thêm 2 ADA
      //})
      //.commit();

    //return tx;
  //} catch (error) {
   // console.error("Lỗi khi tạo giao dịch:", error);
    //throw error;
  //}
//}

// 3. Sử dụng hàm
//const tx = await createSendNativeTokens(
  //"addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw", 
  //"2a5d661ac065dec81c73215d7e667d19ac34ea884f9917a3bc8357fb",
  //"BK03_TOKENS",
  //1n
//);

// 👇 Ký và gửi (cũng dùng .commit())
//const signedTx = await tx.sign().commit();
//const txHash = await signedTx.submit();
//console.log(" Giao dịch thành công! Tx Hash:", txHash);
//Deno.exit(0); // Thoát chương trình
const toAddress = "addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw";

async function createSendAdawithDatum(toAddress: string, datum: any, amount: bigint) {
  const tx = await lucid.newTx()
    .payToWithData(toAddress, datum, { lovelace: amount })
    .commit(); 
  return tx;
}
const VestingSchema = Data.Object({
  lock_until: Data.Integer(),
  beneficiary: Data.Bytes(),
});

const deadlineDate: Date = new Date("2026-06-09T00:00:00Z");
const deadlinePosIx = BigInt(deadlineDate.getTime());
const { payment } = Addresses.inspect(
  "addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw"
);

const d = {
  lock_until: deadlinePosIx,
  beneficiary: payment?.hash
};

const datum = await Data.to<VestingSchema>(d, VestingSchema);

console.log(datum);
//Deno.exit(0); // Thoát chương trình

const tx = await createSendAdawithDatum(toAddress, datum, 100000n);
//console.log(tx);
//Deno.exit(0); // Thoát chương trình

let signedTx = await tx.sign().commit();
let txHash = await signedTx.submit();
console.log('Mã giao dịch là: ' + txHash);