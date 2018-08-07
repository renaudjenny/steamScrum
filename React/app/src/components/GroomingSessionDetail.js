import React from 'react';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import LinearProgress from '@material-ui/core/LinearProgress';
import axios from 'axios';
import moment from 'moment';

class GroomingSessionDetail extends React.Component {

  constructor(props) {
    super(props);
    const sessionId = props.sessionId || props.location.state.sessionId;
    this.state = {
      session: { id: sessionId },
      isGroomingSessionDataLoading: false
    }
  }

  componentDidMount() {
    this.source = axios.CancelToken.source();
    this.refreshGroomingSession();
  }

  componentWillUnmount() {
    this.source.cancel();
  }

  refreshGroomingSession(completion = () => null) {
    this.setState({ isGroomingSessionDataLoading: true });
    axios.get(`/groomingSessions/${this.state.session.id}`, { cancelToken: this.source.token })
    .then((response) => {
      this.setState({
        session: response.data,
        isGroomingSessionDataLoading: false,
      });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      this.setState({ isGroomingSessionDataLoading: false });
    })
    .finally(() => {
      completion();
    });
  }

  render() {
    const groomingSessionDataContent = () => {
      if (this.state.isGroomingSessionDataLoading) {
        return <LinearProgress style={{ width: 300 }} />
      } else {
        const session = this.state.session;
        return (
          <div>
            <Grid item>
              <Typography variant='headline' component='h3'>{session.name}</Typography>
            </Grid>
            <Grid item>
              <Typography component='p'>{moment(session.date).format('LL')}</Typography>
            </Grid>
            {session.userStories &&
              session.userStories.map((userStory) => <UserStory userStory={userStory} />)}
          </div>
        );
      }
    };

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Grooming Session</Typography>
        </Grid>
        {groomingSessionDataContent()}
        <Grid item>
          <Link to='/'>
            <Typography>Les autres sessions</Typography>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

const UserStory = ({ userStory }) => {
  return (
    <Grid item>
      <Typography component='p'>{userStory.name}</Typography>
    </Grid>
  );
}

export default GroomingSessionDetail;
