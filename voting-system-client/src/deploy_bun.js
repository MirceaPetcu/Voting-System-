import React, { useEffect, useState } from 'react';
import logo from './logo.svg';
import './App.css';
import deploy from './utils/deploy_contract/deploy_multibeneficiary';
import web3 from './utils/web3_config';
import MultiBeneficiary from './utils/contracts_info/multibeneficiary.json';

function App() {
  const [account, setAccount] = useState('');
  const [contractAddress, setContractAddress] = useState('');
  const [contract, setContract] = useState(null);

  useEffect(() => {
    const loadBlockchainData = async () => {
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      try {
        const address = await deploy();
        console.log('Contract Address:', address);
        setContractAddress(address);

        // Crează instanța contractului
        const myContract = new web3.eth.Contract(MultiBeneficiary.abi, address);
        setContract(myContract);

        console.log('Contract:', myContract);
      } catch (error) {
        console.error('Could not deploy contract:', error);
      }
    };

    loadBlockchainData();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <p>Account: {account}</p>
        <p>Contract Address: {contractAddress}</p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
