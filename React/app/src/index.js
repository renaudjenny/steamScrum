import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import axios from 'axios';
import Button from '@material-ui/core/Button';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import FlorianRandomSentence from './components/FlorianRandomSentence';
import FlorianSentenceForm from './components/FlorianSentenceForm';

class Sessions extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sessions: []
    }
  }

  componentDidMount() {
    axios.get('/groomingSessions')
    .then((response) => {
      this.setState({ sessions: response.data });
    });
  }

  render() {
    return (
      <div>
        {this.state.sessions.map((session) => <SessionButton value={session} />)}
      </div>
    )
  }
}

function SessionButton({ value }) {
  return (<Button>{value.name}</Button>);
}

// ========================================

const ReactRouter = () => {
  return (
    <Router>
      <div>
        <Route exact path="/" component={Sessions} />
        <Route path='/florian' component={FlorianRandomSentence} />
        <Route path='/florianSentenceForm' component={FlorianSentenceForm} />
      </div>
    </Router>
  );
}

ReactDOM.render(
  <ReactRouter />,
  document.getElementById('root')
);
