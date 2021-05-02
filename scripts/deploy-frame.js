const INITAL_SUPPLY = 100;

async function main() {
  // Create a Frame connection
  const ethProvider = require('eth-provider') // eth-provider is a simple EIP-1193 provider
  const frame = ethProvider('frame') // Connect to Frame

  const ProjectToken = await ethers.getContractFactory("ProjectToken");
  const tx = ProjectToken.getDeployTransaction(INITAL_SUPPLY);

  // Set `tx.from` to current Frame account
  tx.from = (await frame.request({ method: 'eth_requestAccounts' }))[0]

  console.log(
    "Deploying contracts with the account:",
    tx.from
  );

  // Sign and send the transaction using Frame
  const ret = await frame.request({ method: 'eth_sendTransaction', params: [tx] })

  console.log("Token address:", ret);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });