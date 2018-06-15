import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';
import FlorianRandomSentence from './components/FlorianRandomSentence';
import FlorianSentenceForm from './components/FlorianSentenceForm';
import FlorianSentencesList from './components/FlorianSentencesList';
import FlorianSentenceEdit from './components/FlorianSentenceEdit';

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
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Link to='/florian'>
            <Button variant="raised" color="secondary">
              Poser une question à Florian ?
            </Button>
          </Link>
        </Grid>
        <div>
          {this.state.sessions.map((session) => <SessionButton value={session} />)}
        </div>
      </Grid>
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
        <Route path='/florianSentencesList' component={FlorianSentencesList} />
        <Route path='/florianSentenceEdit' component={FlorianSentenceEdit} />
      </div>
    </Router>
  );
}

ReactDOM.render(
  <ReactRouter />,
  document.getElementById('root')
);
