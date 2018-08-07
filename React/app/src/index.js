import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';
import FlorianRandomSentence from './components/FlorianRandomSentence';
import FlorianSentenceForm from './components/FlorianSentenceForm';
import FlorianSentencesList from './components/FlorianSentencesList';
import FlorianSentenceEdit from './components/FlorianSentenceEdit';
import GroomingSessionsList from './components/GroomingSessionsList';
import GroomingSessionForm from './components/GroomingSessionForm';
import GroomingSessionDetail from './components/GroomingSessionDetail';

const Sessions = (props) => {
  return (
    <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
      <Grid item>
        <Typography variant='title' component="h2">Choisissez une session de grooming</Typography>
      </Grid>
      <GroomingSessionsList />
      <Grid item>
        <Link to='/groomingSessionForm'>
          <Button variant="raised" color='primary'>
            Créer une session de grooming
          </Button>
        </Link>
      </Grid>
      <Grid>
        <Link to='/florian'>
          <Button variant="raised" color="secondary">
            Poser une question à Florian ?
          </Button>
        </Link>
      </Grid>
    </Grid>
  )
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
        <Route path='/groomingSessionForm' component={GroomingSessionForm} />
        <Route path='/groomingSessionDetail' component={GroomingSessionDetail} />
      </div>
    </Router>
  );
}

ReactDOM.render(
  <ReactRouter />,
  document.getElementById('root')
);
