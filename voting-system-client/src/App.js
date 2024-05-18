import {React, useEffect} from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MainPage from './components/MainPage';
import CreatePollPage from './components/CreatePollPage';
import Contribute from './components/Contribute';
import VotePollPage from './components/VotePollPage';
function App() {
  useEffect(() => {
    localStorage.clear();
  }
  , []);
  
  return (
    <Router>
      <Routes>
        <Route path="/" element={<MainPage />} />
        <Route path="/create" element={<CreatePollPage />} />
        <Route path="/contribute" element={<Contribute />} />
        <Route path="/vote" element={<VotePollPage />} />

      </Routes>
    </Router>
  );
}

export default App;
