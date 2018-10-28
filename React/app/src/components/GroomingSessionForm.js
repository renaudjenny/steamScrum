import React from 'react';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import LinearProgress from '@material-ui/core/LinearProgress';
import axios from 'axios';
import moment from 'moment';

class GroomingSessionForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      newGroomingSession: null,
      currentGroomingSession: { name: '', date: new Date() },
      groomingSessionsCount: 0,
      maximumGroomingSessionsCount: 0,
      isGroomingSessionDataLoading: false,
    }
    this.source = null;
    this.mountPromise = Promise.resolve();
    this.addSubmitPromise = Promise.resolve();
  }

  componentDidMount() {
    this.source = axios.CancelToken.source();
    this.mountPromise = this.refreshContext();
  }

  componentWillUnmount() {
    this.source.cancel();
  }

  refreshContext(completion = () => null) {
    this.setState({ isGroomingSessionDataLoading: true });
    return axios.get('/groomingSessionsContext', { cancelToken: this.source.token })
    .then((response) => {
      const { groomingSessionsCount, maximumGroomingSessionsCount } = response.data;
      return this.setState({
        groomingSessionsCount: groomingSessionsCount,
        maximumGroomingSessionsCount: maximumGroomingSessionsCount,
        isGroomingSessionDataLoading: false,
      });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      return this.setState({ isGroomingSessionDataLoading: false });
    })
    .finally(() => {
      completion();
    });
  }

  handleGroomingSessionNameChange(event) {
    const currentGroomingSession = this.state.currentGroomingSession;
    currentGroomingSession.name = event.target.value;
    this.setState({ currentGroomingSession })
  }

  handleGroomingSessionDateChange(event) {
    const currentGroomingSession = this.state.currentGroomingSession;
    currentGroomingSession.date = moment(event.target.value, 'YYYY-MM-DD').toDate();
    this.setState({ currentGroomingSession })
  }

  submit(completion = () => null) {
    const data = {
      name: this.state.currentGroomingSession.name,
      date: moment(this.state.currentGroomingSession.date).format(),
    };

    this.addSubmitPromise = axios.post(
      '/groomingSessions',
      data,
      { cancelToken: this.source.token }
    ).then((response) => {
      this.setState({ newGroomingSession: response.data });
      return this.refreshContext(() => {
        completion();
      });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        completion();
        return;
      }
      completion();
      return;
    })
  }

  render() {
    const groomingSessionDataContent = () => {
      if (this.state.isGroomingSessionDataLoading) {
        return <LinearProgress style={{ width: 300 }} />
      } else {
        return <Typography component="p">
            Already saved Grooming Sessions: <strong>{this.state.groomingSessionsCount}/{this.state.maximumGroomingSessionsCount}</strong>
          </Typography>
      }
    };

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Add a Grooming Session</Typography>
        </Grid>
        <Grid item>
          {groomingSessionDataContent()}
        </Grid>
        <Grid item>
          <TextField
            id="groomingSessionName"
            label="Session name"
            value={this.state.currentGroomingSession.name}
            onChange={(event) => this.handleGroomingSessionNameChange(event)}
          />
        </Grid>
        <Grid item>
          <TextField
            id='groomingSessionDate'
            label="Session date"
            value={moment(this.state.currentGroomingSession.date).format('YYYY-MM-DD')}
            onChange={(event) => this.handleGroomingSessionDateChange(event)}
            type='date'
          />
        </Grid>
        <Grid>
          <Button variant="raised" color="primary" onClick={() => this.submit()}>Add</Button>
        </Grid>
        {this.state.newGroomingSession !== null &&
          <Grid item>
            <Typography componenent="p" id='newGroomingSessionInfo'>Your new Session: <strong>{this.state.newGroomingSession.name}</strong> is saved</Typography>
          </Grid>
        }
        <Grid item>
          <Link to='/'>
            <Typography>Other Sessions</Typography>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default GroomingSessionForm;
