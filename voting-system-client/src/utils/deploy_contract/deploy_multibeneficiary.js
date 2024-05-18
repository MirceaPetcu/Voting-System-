// /*global BigInt*/
// import web3 from '../web3_config';
// import MultiBeneficiary from '../contracts_info/multibeneficiary.json';

// const deploy = async () => {
  //   const accounts = await web3.eth.getAccounts();
  //   const contract = new web3.eth.Contract(MultiBeneficiary.abi);
  
  //   try {
  //     const gasEstimate = await contract.deploy({
  //       data: MultiBeneficiary.bytecode,
  //     }).estimateGas({ from: accounts[0] });
  
  //     const gasEstimateBigInt = BigInt(gasEstimate);
  //     const margin = BigInt(20); // Convertim procentul de marjă la BigInt
  //     const oneHundred = BigInt(100); // Convertim 100 la BigInt pentru calcule
  //     const gasWithSafetyMargin = gasEstimateBigInt + (gasEstimateBigInt * margin / oneHundred);
  
  //     const nonce = await web3.eth.getTransactionCount(accounts[0], 'latest');
  //     let receipt = await web3.eth.getTransactionReceipt(`0x${nonce.toString(16)}`); // Conversie explicită a nonce-ului la hexadecimal string
  
  //     while (!receipt) {
  //       console.log('Așteptăm ca nonce-ul să fie actualizat...');
  //       await new Promise(resolve => setTimeout(resolve, 2000)); // Așteaptă 2 secunde
  //       receipt = await web3.eth.getTransactionReceipt(`0x${(nonce - BigInt(1)).toString(16)}`); // Folosim BigInt pentru nonce
  //     }
  
  //     console.log('Ultima tranzacție cu nonce-ul ', nonce - BigInt(1), ' a fost procesată. Nonce-ul curent: ', nonce);
  //     console.log(`Estimated Gas with Safety Margin: ${gasWithSafetyMargin}`);
  //     console.log(`Using nonce: ${nonce}`);
  
  //     const result = await contract
  //       .deploy({ data: MultiBeneficiary.bytecode })
  //       .send({
  //         gas: gasWithSafetyMargin.toString(), // Asigură-te că convertim la string pentru a trimite
  //         from: accounts[0],
  //         nonce: `0x${nonce.toString(16)}`  // Convertim nonce la hexadecimal string
  //       });
  
  //     console.log('Contract deployed to', result.options.address);
  //     return result.options.address;
  //   } catch (error) {
  //     console.error('Error deploying contract:', error);
  //     throw error;
  //   }

//   const contract = new web3.eth.Contract(MultiBeneficiary.abi);
//   web3.eth.getAccounts().then(async (accounts) => {
//     // Display all Ganache Accounts
//     console.log("Accounts:", accounts);
 
//     const mainAccount = accounts[0];
//     const nonce = await web3.eth.getTransactionCount(accounts[0], 'latest');

 
//     // address that will deploy smart contract
//     console.log("Default Account:", mainAccount);
//     contract
//         .deploy({ data: MultiBeneficiary.bytecode })
//         .send({ from: mainAccount, gas: 10000000, nonce: `0x${nonce.toString(16)}`})
//         .on("receipt", (receipt) => {
 
//             // Contract Address will be returned here
//             console.log("Contract Address:", receipt.contractAddress);
//         })
//         .then((initialContract) => {
//             initialContract.methods.getBeneficiaries().call((err, data) => {
//                 console.log("Initial Data:", data);
//             });
//         });
// });

// };
  
// export default deploy;

// For simplicity we use `web3` package here. However, if you are concerned with the size,
//	you may import individual packages like 'web3-eth', 'web3-eth-contract' and 'web3-providers-http'.
// import { Web3 } from 'web3';
// import fs from 'fs';
// import path from 'path';

import web3 from '../web3_config';
import MultiBeneficiary from '../contracts_info/multibeneficiary.json';

const bytecode = MultiBeneficiary.bytecode;

const abi = MultiBeneficiary.abi;
const myContract= new web3.eth.Contract(abi);
myContract.handleRevert = true;

async function deploy(){
	const providersAccounts = await web3.eth.getAccounts();
	const defaultAccount = providersAccounts[0];
	console.log('deployer account:', defaultAccount);

  const addr = localStorage.getItem('pollsystemContractAddress');
  console.log('Address:', addr);
	const contractDeployer = myContract.deploy({
		data: '0x' + bytecode,
		arguments: [addr],
	});


	const gas = await contractDeployer.estimateGas({
		from: defaultAccount,
	});
	console.log('estimated gas:', gas);

	try {
    const nonce = await web3.eth.getTransactionCount(defaultAccount, 'latest');

		const tx = await contractDeployer.send({
			from: defaultAccount,
			gas,
			gasPrice: 50000000000,
      nonce: `0x${nonce.toString(16)}`
		});
		console.log('Contract deployed at address: ' + tx.options.address);
    localStorage.setItem('contractAddress', tx.options.address);

    return tx.options.address;
		// const deployedAddressPath = path.join(__dirname, 'MyContractAddress.bin');
		// fs.writeFileSync(deployedAddressPath, tx.options.address);
	} catch (error) {
		console.error(error);
	}
}

export default deploy;
