import React, { useState, useEffect } from 'react';
import deploy from '../utils/deploy_contract/deploy_contribuitor';
import web3 from '../utils/web3_config';
import Contribuitor from '../utils/contracts_info/contribuitor.json';
import Poll from '../utils/contracts_info/polls.json';
import Escrow from '../utils/contracts_info/escrow.json';

const VotePollPage = () => {
  const [polls, setPolls] = useState([]);
    const [account, setAccount] = useState('');
    const [contract, setContract] = useState(null);
    const [contractAddress, setContractAddress] = useState(); // Adresa contractului deployat
    const [balance, setBalance] = useState(0);

    useEffect(() => {
      const loadBlockchainData = async () => {
        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[1]);
        const balance = await web3.eth.getBalance(accounts[1]);

        setBalance(web3.utils.fromWei(balance, 'ether'));
  
        try {
          const address = await deploy();
          console.log('Contract Address:', address);
          setContractAddress(address);
  
          // Crează instanța contractului
          const myContract = new web3.eth.Contract(Contribuitor.abi, address);
          setContract(myContract);


          
          console.log('Contract:', myContract);
        } catch (error) {
          console.error('Could not deploy contract:', error);
        }
      };
  
      loadBlockchainData();
    }, []);

    const handleClick = async () => {
      await contract.methods.contrib().send({
          from: account,
          value: web3.utils.toWei('1000', 'ether') // Sending 0.1 Ether (in Wei)
      });
          alert('Contributed successfully!');
    }

    return (
        <div>
            <h1>Active Polls</h1>
            <p>Account: {account}</p>
            <p>Balance: {balance} ETH</p>
            <div>
              <button onClick={handleClick}>Send 10 ETH</button>
            </div>
        </div>
    );

};

export default VotePollPage;
