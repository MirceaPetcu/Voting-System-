import React, { useState, useEffect } from 'react';
import web3 from '../utils/web3_config';
import PollSystem from '../utils/contracts_info/pollsystem.json';

const VotePollPage = () => {
    const [account, setAccount] = useState('');
    const [balance, setBalance] = useState(0);
    const [contract, setContract] = useState(null);
    const [polls, setPolls] = useState([]);
    const [voteInput, setVoteInput] = useState({}); // Object to store votes for each poll
    const [ethAmount, setEthAmount] = useState({}); // Object to store ETH amount for each vote

    // Function to fetch the user's ETH balance
    const fetchBalance = async (account) => {
        try {
            const balance = await web3.eth.getBalance(account);
            setBalance(web3.utils.fromWei(balance, 'ether'));
        } catch (error) {
            console.error('Error fetching balance:', error);
        }
    };

    // Function to fetch all polls
    const fetchPolls = async () => {
        if (!contract) return;

        const pollCount = await contract.methods.getPollCount().call({ from: account });
        const pollsArray = [];

        for (let i = 0; i < pollCount; i++) {
            const pollData = await contract.methods.getPoll(i).call();
            console.log(`typeof pollData`, typeof pollData);

            try {
                const [title, description, options, deadline] = pollData.split(';');
                const optionsArray = options ? options.split(',') : [];

                pollsArray.push({
                    id: i,
                    title,
                    description,
                    options: optionsArray,
                    deadline
                });
            } catch (error) {
                console.error(`Error decoding poll data for poll ${i}:`, error);
            }
        }

        setPolls(pollsArray);
    };

    const handleVoteChange = (pollId, index) => {
        setVoteInput({ ...voteInput, [pollId]: index });
    };

    const handleEthAmountChange = (pollId, value) => {
        setEthAmount({ ...ethAmount, [pollId]: value });
    };

    const handleVoteSubmit = async (pollId) => {
        try {
            const ethValue = ethAmount[pollId] ? web3.utils.toWei(ethAmount[pollId], 'ether') : '0';
            await contract.methods.vote(pollId, voteInput[pollId]).send({ from: account, value: ethValue, gas: 3000000 });
            alert('Vote submitted successfully!');
            fetchPolls(); // Refresh the polls to reflect the updated votes
            fetchBalance(account); // Refresh the user's balance
        } catch (error) {
            alert('Error submitting vote: ' + error.message);
        }
    };

    useEffect(() => {
        const loadBlockchainData = async () => {
            try {
                const accounts = await web3.eth.getAccounts();
                setAccount(accounts[1]);
                fetchBalance(accounts[1]); // Fetch balance initially

                const contractAddress = localStorage.getItem('pollsystemAddress');

                if (!contractAddress) {
                    throw new Error('Contract address not found in local storage');
                }

                const contractInstance = new web3.eth.Contract(PollSystem.abi, contractAddress);
                setContract(contractInstance);

                console.log('Contract instance created:', contractInstance);

            } catch (error) {
                console.error('Could not load contract or blockchain data:', error);
            }
        };

        loadBlockchainData();
    }, []);

    useEffect(() => {
        fetchPolls();
    }, [contract]);

    return (
        <div>
            <h1>Vote on Polls</h1>
            <p>Account: {account}</p>
            <p>Balance: {balance} ETH</p>
            <div>
                {polls.length > 0 ? (
                    polls.map((poll) => (
                        <div key={poll.id}>
                            <h2>{poll.title}</h2>
                            <p>{poll.description}</p>
                            <form onSubmit={(e) => { e.preventDefault(); handleVoteSubmit(poll.id); }}>
                                {poll.options.map((option, index) => (
                                    <div key={index}>
                                        <input
                                            type="radio"
                                            id={`poll-${poll.id}-option-${index}`}
                                            name={`poll-${poll.id}`}
                                            value={index}
                                            onChange={() => handleVoteChange(poll.id, index)}
                                            required
                                        />
                                        <label htmlFor={`poll-${poll.id}-option-${index}`}>{option}</label>
                                    </div>
                                ))}
                                <input
                                    type="number"
                                    step="0.01"
                                    min="0"
                                    value={ethAmount[poll.id] || ''}
                                    onChange={(e) => handleEthAmountChange(poll.id, e.target.value)}
                                    placeholder="ETH amount"
                                    required
                                />
                                <button type="submit">Vote</button>
                            </form>
                            
                        </div>
                    ))
                ) : (
                    <p>Loading polls...</p>
                )}
            </div>
        </div>
    );
};

export default VotePollPage;
