import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MainPage from './components/MainPage';
import CreatePollPage from './components/CreatePollPage';
import VotePollPage from './components/VotePollPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<MainPage />} />
        <Route path="/create" element={<CreatePollPage />} />
        <Route path="/vote" element={<VotePollPage />} />
      </Routes>
    </Router>
  );
}

export default App;
