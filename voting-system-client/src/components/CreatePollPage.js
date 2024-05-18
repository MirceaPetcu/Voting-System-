import React, { useState, useEffect } from 'react';
import deploy from '../utils/deploy_contract/deploy_multibeneficiary';
import web3 from '../utils/web3_config';
import MultiBeneficiary from '../utils/contracts_info/multibeneficiary.json';
import PollSystem from '../utils/contracts_info/pollsystem.json';

const CreatePollPage = () => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [options, setOptions] = useState('');
    const [deadline, setDeadline] = useState('');
    const [contractMultibeneficiary, setContractMultibeneficiary] = useState(null);
    const [contractPollsystem, setContractPollsystem] = useState(null);
    const [address, setAddress] = useState(''); // Address for new beneficiary
    const [beneficiaries, setBeneficiaries] = useState([]); // State for storing beneficiaries
    const [pollsMoney, setPollsMoney] = useState([]); // State for storing the amount of money each poll has

    const fetchBeneficiariesMoney = async () => {
        for (let i = 0; i < beneficiaries.length; i++) {
            const balance = await web3.eth.getBalance(beneficiaries[i].address);
            const balanceETH = web3.utils.fromWei(balance, 'ether');
            beneficiaries[i].balance = balanceETH;
        }
    }
    const fetchEscrows = async () => {
        if (!contractPollsystem) return;

        const pollCount = await contractPollsystem.methods.getPollCount().call({ from: beneficiaries[0].address });
        const pollsArray = [];

        for (let i = 0; i < pollCount; i++) {
            const pollData = await contractPollsystem.methods.getPoll(i).call();
            const escrowData = await contractPollsystem.methods.getAmountFromEscrow(i).call();
            const escrowETH = web3.utils.fromWei(escrowData, 'ether');
            console.log("escrowData:", web3.utils.fromWei(escrowData, 'ether'));
            console.log(`typeof pollData`, typeof pollData);

            try {
                const [title, description, options, deadline] = pollData.split(';');
                

                pollsArray.push({
                    id: i,
                    title,
                    escrowETH
                });
            } catch (error) {
                console.error(`Error decoding poll data for poll ${i}:`, error);
            }
        }

        setPollsMoney(pollsArray);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const optionsArray = options.split(',').map(option => option.trim().toString()); // Transformă opțiunile într-un array, separându-le prin virgulă
        const deadlineTimestamp = Math.floor(new Date(deadline).getTime() / 1000); // Converteste deadline-ul în timestamp

        try {
            
            const add = await contractMultibeneficiary.methods.createPoll(title, description, optionsArray, deadlineTimestamp).send({ from: beneficiaries[0].address, gas: 30000000});

            console.log('Add:', add);
            alert('Poll created successfully!');
            fetchEscrows();
        } catch (error) {
            alert('Error creating poll: ' + error.message);
        }
    };

    const handleAddressSubmit = async (e) => {
        e.preventDefault();
        try {
            await contractMultibeneficiary.methods.addBeneficiary(address).send({ from: beneficiaries[0].address, gas: 30000000 });
            
            const beneficiaryBalance = await web3.eth.getBalance(address);
            const beneficiaryData = {
                address: address,
                balance: web3.utils.fromWei(beneficiaryBalance, 'ether')
            };

            const updatedBeneficiaries = [...beneficiaries, beneficiaryData];
            setBeneficiaries(updatedBeneficiaries);
            localStorage.setItem('beneficiaries', JSON.stringify(updatedBeneficiaries));

            alert('Address submitted successfully!');
        } catch (error) {
            alert('Error submitting address: ' + error.message);
        }
    }

    const handleReleaseSubmit = async (index) => {
        try {
            await contractPollsystem.methods.releaseFunds(index).send({ from: beneficiaries[0].address, gas: 3000000 });
            alert('ETH released successfully!');
            fetchEscrows();
            fetchBeneficiariesMoney();
        } catch (error) {
            alert('Error releasing ETH: ' + error.message);
        }
    };


    useEffect(() => {
        const loadBlockchainData = async () => {
          const accounts = await web3.eth.getAccounts();
          const balance = await web3.eth.getBalance(accounts[0]);
          console.log("Beneficiaries", beneficiaries);
          
          if(localStorage.getItem('beneficiaries') === null) {
            const beneficiaryData = {
                    address: accounts[0],
                    balance: web3.utils.fromWei(balance, 'ether')
                };
            const updatedBeneficiaries = [...beneficiaries, beneficiaryData];
            setBeneficiaries(updatedBeneficiaries);
            localStorage.setItem('beneficiaries', JSON.stringify(updatedBeneficiaries));
          }
          else {
            const data = JSON.parse(localStorage.getItem('beneficiaries'));
            setBeneficiaries(data);
          } 
          try {
            const multibeneficiaryAddress = localStorage.getItem('multibeneficiaryAddress');
            const pollsystemAddress = localStorage.getItem('pollsystemAddress');

            const multibeneficiaryContract = new web3.eth.Contract(MultiBeneficiary.abi, multibeneficiaryAddress);
            const pollsystemContract = new web3.eth.Contract(PollSystem.abi, pollsystemAddress);

            setContractMultibeneficiary(multibeneficiaryContract);
            setContractPollsystem(pollsystemContract);

    
            // console.log('Contract:', myContract);
          } catch (error) {
            console.error('Could not deploy contract:', error);
          }
        };
        
        
            loadBlockchainData();
        
      }, []);

      useEffect(() => {
        fetchEscrows();
    }, [contractPollsystem]);
    return (
        <div>
            <div>
                <h1>Create a New Poll</h1>
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
                <h3>Beneficiaries</h3>
                <ul>
                    {beneficiaries.map((beneficiary, index) => (
                        <li key={index}>
                            <p>Address: {beneficiary.address}</p>
                            <p>Balance: {beneficiary.balance} ETH</p>
                        </li>
                    ))}
                </ul>
            </div>
            <div>
                <h2>Polls and the amount of ETH they have</h2>
                {pollsMoney.length > 0 ? (
                    pollsMoney.map((poll, index) => (
                        <div key={poll.id}>
                            <h2>{poll.title}: {poll.escrowETH} ETH </h2>
                            <button onClick={() => handleReleaseSubmit(poll.id)}>Release ETH</button>
                        </div>
                    ))
                ) : (
                    <p>Loading polls...</p>
                )}
            </div>
        </div>
    );
};

export default CreatePollPage;
