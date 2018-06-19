import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
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
      console.log('success')
      this.setState({ sessions: response.data });
    })
    .catch(() => {
      console.log('error')
      this.setState({ sessions: [{ name: 'Error' }, { name: 'Error2' }] });
    });
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='title' component="h2">Choisissez une session de grooming</Typography>
        </Grid>
        <List style={{ width: '100%', maxWidth: 360 }}>
          {this.state.sessions.map((session) => <SessionItem key={`session_${session.id}`} value={session} />)}
        </List>
        <Grid item>
          <Link to='/florian'>
            <Button variant="raised" color="secondary">
              Poser une question à Florian ?
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

function SessionItem({ value }) {
  return (
    <ListItem button>
      <ListItemText primary={value.name} />
    </ListItem>
  );
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
