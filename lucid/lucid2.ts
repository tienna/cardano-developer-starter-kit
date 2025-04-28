import { Blockfrost, Lucid, Crypto ,fromText,Data, Addresses, } from "https://deno.land/x/lucid/mod.ts";

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewjeV1C6kZZcdvOk8U2RS7DnGt5XwwvaWS"
  ),
}); 


const seed="receive company catalog screen erase shallow verb wool asthma bring north average side chunk bulk submit hip spend antique unaware purity right fat someone"
lucid.selectWalletFromSeed(seed,{addressType:"Base", index:0})

const address = await lucid.wallet.address(); // Bech32 address
console.log(`D/c ví gửi: ${address}`);

async function createMintingScripts(slot_in: bigint) {
    const { payment } = Addresses.inspect(
      await lucid.wallet.address(),
    );
  
    const mintingScripts = lucid.newScript({
      type: "All",
      scripts: [
        { type: "Sig", keyHash: payment.hash },
        {
          type: "Before",
          slot: slot_in
        },
      ],
    },
  );
  
    return mintingScripts;
  }
  async function mintToken(policyId: string, tokenName: string, amount: bigint, slot_in: bigint) {
    const unit = policyId + fromText(tokenName);
  
    // ================= Tạo metadata ====
    const metadata = {
      [policyId]: {
        [tokenName]: {
          "description": "This is Token minted by LUCID",
          "name": `${tokenName}`,
          "id":1 ,
          "image": "ipfs://QmRoaRZ7QGX9EiLkZoGJfC5is9VUN19P8nsra2aWqoDUm1"
        }
      }
    };
  
    console.log(metadata);
   
    const tx = await lucid.newTx()
      .mint({ [unit]: amount })
      .validTo(Date.now() + 200000)
      .attachScript(await createMintingScripts(slot_in))
      .attachMetadata(721, metadata)
      .commit();

return tx;

  }

  const slot_in = BigInt(lucid.utils.unixTimeToSlots(Date.now())); //BigInt(84885593).
  console.log(`Slot: ${slot_in}`);
  Deno.exit(0); //.Thoat . chương. trinh
  
  
  
  
    