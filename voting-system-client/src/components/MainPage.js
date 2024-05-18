import {React, useEffect} from 'react';
import { Link } from 'react-router-dom';
import deployMultibeneficiary from '../utils/deploy_contract/deploy_multibeneficiary';
import deployPollsystem from '../utils/deploy_contract/deploy_pollsystem';

const MainPage = () => {


  useEffect(() => {
    const loadBlockchainData = async () => {
      try {
        if(!localStorage.getItem('multibeneficiaryAddress') || !localStorage.getItem('pollsystemAddress')){
          const addressPollsystem = await deployPollsystem();
          const addressMultibeneficiary = await deployMultibeneficiary();
  
          localStorage.setItem('multibeneficiaryAddress', addressMultibeneficiary);
          localStorage.setItem('pollsystemAddress', addressPollsystem);
  
        }
       
        

      } catch (error) {
        console.error('Could not deploy contract:', error);
      }
    };

    loadBlockchainData();
  }, []);

  return (
    <div>
      <h1>Welcome to the Poll App</h1>
      <Link to="/create"><button>Create Poll</button></Link>
      <Link to="/contribute"><button> Contribute</button></Link>
      <Link to="/vote"><button> Vote</button></Link>
    </div>
  );
};

export default MainPage;
