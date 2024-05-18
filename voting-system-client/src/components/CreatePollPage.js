import React, { useState, useEffect } from 'react';
import deploy from '../utils/deploy_contract/deploy_multibeneficiary';
import web3 from '../utils/web3_config';
import MultiBeneficiary from '../utils/contracts_info/multibeneficiary.json';

const CreatePollPage = () => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [options, setOptions] = useState('');
    const [deadline, setDeadline] = useState('');
    const [account, setAccount] = useState('');
    const [contractAddress, setContractAddress] = useState('');
    const [contract, setContract] = useState(null);
    const [balance, setBalance] = useState(0);
    const [address, setAddress] = useState(''); // Adresa pentru noul input


    const handleSubmit = async (e) => {
        e.preventDefault();
        const optionsArray = options.split(',').map(option => option.trim().toString()); // Transformă opțiunile într-un array, separându-le prin virgulă
        const deadlineTimestamp = Math.floor(new Date(deadline).getTime() / 1000); // Converteste deadline-ul în timestamp

        try {
            
            // Apelul metodei createPoll din contract
            const add = await contract.methods.createPoll(title, description, optionsArray, deadlineTimestamp).send({ from: account, gas: 30000000});

            console.log('Add:', add);
            const pastPoll = await contract.getPastEvents('PollCreated', {
                fromBlock: 0,
                toBlock: 'latest'
            });

            const pastEscrow = await contract.getPastEvents('EscrowCreated', {
                fromBlock: 0,
                toBlock: 'latest'
            });

            
            const polls = []
            for (let i = 0; i < pastPoll.length; i++) {
                const poll = pastPoll[i].address;
                polls.push(poll);
            }

            const escrows = []
            for (let i = 0; i < pastEscrow.length; i++) {
                const escrow = pastEscrow[i].address;
                escrows.push(escrow);
            }

            localStorage.setItem('polls', JSON.stringify(polls));
            localStorage.setItem('escrows', JSON.stringify(escrows));

            console.log('Past Polls:', pastPoll)
            console.log('Past Escrows:', pastEscrow)
            alert('Poll created successfully!');
        } catch (error) {
            alert('Error creating poll: ' + error.message);
        }
    };

    const handleAddressSubmit = async (e) => {
        e.preventDefault();
        try {
            // Apelul metodei addBeneficiary din contract
            await contract.methods.addBeneficiary(address).send({ from: account, gas: 30000000 });
            alert('Address submitted successfully!');
        } catch (error) {
            alert('Error submitting address: ' + error.message);
        }
    }


    useEffect(() => {
        const loadBlockchainData = async () => {
          const accounts = await web3.eth.getAccounts();
          setAccount(accounts[0]);
          const balance = await web3.eth.getBalance(accounts[0]);

          setBalance(web3.utils.fromWei(balance, 'ether'));
    
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
        <div>
            <div>
                <h1>Create a New Poll</h1>
                <p>Account: {account}</p>
                <p>Balance: {balance}</p>
                <form onSubmit={handleSubmit}>
                    <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Title" required />
                    <textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description" required />
                    <input type="text" value={options} onChange={(e) => setOptions(e.target.value)} placeholder="Options, separated by commas" required />
                    <input type="date" value={deadline} onChange={(e) => setDeadline(e.target.value)} placeholder="Deadline" required />
                    <button type="submit">Create Poll</button>
                </form>
            </div>
            <div>
                <h2>Submit Address</h2>
                <form onSubmit={handleAddressSubmit}>
                    <input type="text" value={address} onChange={(e) => setAddress(e.target.value)} placeholder="Enter Address" required />
                    <button type="submit">Submit Address</button>
                </form>
            </div>
        </div>
    );
};

export default CreatePollPage;
