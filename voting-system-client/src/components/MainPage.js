import React from 'react';
import { Link } from 'react-router-dom';

const MainPage = () => {
  return (
    <div>
      <h1>Welcome to the Poll App</h1>
      <Link to="/create"><button>Create Poll</button></Link>
      <Link to="/vote"><button> Contribute</button></Link>
    </div>
  );
};

export default MainPage;
