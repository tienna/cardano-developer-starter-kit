import { Blockfrost, Lucid, Crypto } from "https://deno.land/x/lucid/mod.ts";

// Provider selection
// There are multiple builtin providers you can choose from in Lucid.

// Blockfrost

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewFyzaqUx3TF5Ym6S38Rb9qaB0V2rWYRkD",
  ),
});

//console.log(lucid); 

const seed = "kitchen tissue session acid wet very sentence weekend carpet mountain liberty blush elite remember legal laugh brother crystal lava initial tide fame manage whale"
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0 });
console.log(lucid); 
// const privateKey = await Deno.readTextFile("./privateKey");
// lucid.selectWalletFromPrivateKey(privateKey);

// Get address
const address = await lucid.wallet.address(); // Bech32 address
console.log (`Đ/c ví gửi: ${address}`) //Hiện thị địa chỉ ví

const utxos = await lucid.utxosAt(address);
console.log (utxos) //Hiện thị toàn bộ UTxOs

const utxo=utxos[0];
console.log(utxo) //Hiện thị 1 UTxO
console.log (`lovelace: ${utxo.assets.lovelace}`) //Hiện thị 1 UTxO

// Lấy thông tin assets từ UTxO
const assets = utxo.assets;

// Hiển thị thông tin assets
console.log("Assets:", assets);


// Hiển thị toàn bộ tài sản và giá trị của chúng
for (const assetname in assets) {
console.log(`Assetname: ${assetname}, Value: ${assets[assetname]}`);
}

// Query scriptUtxo
const [scriptUtxo] = await lucid.utxosAt("addr_test1wrv8xtfuwyfsq2zhur8es0aw4pq6uz73um8a4507dj6wkqc4yccnh");
console.log(scriptUtxo)

const datum = await lucid.datumOf(scriptUtxo);
console.log(datum)

//đọc datum từ hash 
const datumcbor = await lucid.provider.getDatum("602ca110fe0b1874444086afb8e9e98ecf4372ff7cf44268531249bf793c9065");
console.log (`datum: ${datumcbor}`) 

const protocolParameters = await lucid.provider.getProtocolParameters();
console.log(protocolParameters)

// Create transaction==============================
//const tx = await lucid.newTx()

//.payTo("addr_test1qrjgrt0eqjlrn3wkd6m6rpllkzjff0xldchhl8jzwx430tkf4wx2mtkjxk0cqxgsh0t9rrfapzzgs0l4mlvh4uwsqvys3upzzm", { lovelace: 100000000n }) 
////.commit();

//console.log(`tx: ${tx}`) //Hiện thị tx

// Sign transaction
//const signedTx = await tx.sign().commit();
//console.log(`signedTx: ${signedTx}`) //Hiện thị tx

// Submit transaction
//const txHash = await signedTx.submit();

// Print transaction hash
//console.log(`Mã giao dịch là: ${txHash}`);

const toAddress = "addr_test1qrjgrt0eqjlrn3wkd6m6rpllkzjff0xldchhl8jzwx430tkf4wx2mtkjxk0cqxgsh0t9rrfapzzgs0l4mlvh4uwsqvys3upzzm";
const amount = 3000000n;
const metadata = { msg: ["Hello C2VN_BK02. This is metadata 674"] };

const tx = await lucid.newTx()
.payTo(toAddress, { lovelace: amount })
.attachMetadata(674, metadata)
.commit();

const signedTx = await tx.sign().commit();

const txHash = await signedTx.submit();

console.log(`Mã giao dịch là: ${txHash}`)
