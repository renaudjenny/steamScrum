import React from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import MainPage from "./MainPage";
import FlorianRandomSentence from './FlorianRandomSentence';
import FlorianSentenceForm from './FlorianSentenceForm';
import FlorianSentencesList from './FlorianSentencesList';
import FlorianSentenceEdit from './FlorianSentenceEdit';
import GroomingSessionForm from './GroomingSessionForm';
import GroomingSessionDetail from './GroomingSessionDetail';

const ReactRouter = () => {
  return (
    <Router>
      <div>
        <Route exact path="/" component={MainPage} />
        <Route path='/florian' component={FlorianRandomSentence} />
        <Route path='/florianSentenceForm' component={FlorianSentenceForm} />
        <Route path='/florianSentencesList' component={FlorianSentencesList} />
        <Route path='/florianSentenceEdit' component={FlorianSentenceEdit} />
        <Route path='/groomingSessionForm' component={GroomingSessionForm} />
        <Route path='/groomingSessionDetail' component={GroomingSessionDetail} />
      </div>
    </Router>
  );
}

export default ReactRouter;
