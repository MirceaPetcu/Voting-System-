import Web3 from 'web3';

// Conectează-te la provider-ul Ganache
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));

export default web3;
