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

class Index extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sessionsCount: 0,
    };
  }

  render() {
    let title = 'There is no Grooming Sessions available yet. Go create some!';
    if (this.state.sessionsCount > 0) {
      title = 'Choose a Grooming Session';
    }

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='title' component="h2">{title}</Typography>
        </Grid>
        <GroomingSessionsList countCallback={(count) => this.setState({sessionsCount: count})} />
        <Grid item>
          <Link to='/groomingSessionForm'>
            <Button variant="raised" color='primary'>
              Create Grooming Session
            </Button>
          </Link>
        </Grid>
        <Grid>
          <Link to='/florian'>
            <Button variant="raised" color="secondary">
              Ask Florian!
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

// ========================================

const ReactRouter = () => {
  return (
    <Router>
      <div>
        <Route exact path="/" component={Index} />
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

const root = document.getElementById('root');
if (root) {
  ReactDOM.render(<ReactRouter />, root);
}
