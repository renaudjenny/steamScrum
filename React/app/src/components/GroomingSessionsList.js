import React from 'react';
import axios from 'axios';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';

class GroomingSessionsList extends React.Component {

  constructor(props) {
    super(props);
    this.state = { sessions: [] }
  }

  componentDidMount() {
    this.source = axios.CancelToken.source();
    this.refreshGroomingSessions();
  }

  componentWillUnmount() {
    this.source.cancel();
  }

  refreshGroomingSessions(completion = () => null) {
    axios.get('/groomingSessions', { cancelToken: this.source.token })
    .then((response) => {
      this.setState({ sessions: response.data });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      console.error(error);
    })
    .finally(() => {
      completion();
    });
  }

  render() {
    return (
      <List style={{ width: '100%', maxWidth: 360 }}>
        {this.state.sessions.map((session) => <SessionItem key={`session_${session.id}`} value={session} />)}
      </List>
    );
  }
}

const SessionItem = ({ value }) => {
  return (
    <ListItem button>
      <ListItemText primary={value.name} />
    </ListItem>
  );
};

export default GroomingSessionsList;
