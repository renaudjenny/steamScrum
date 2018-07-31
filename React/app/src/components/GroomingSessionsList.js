import React from 'react';
import axios from 'axios';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import IconButton from '@material-ui/core/IconButton';
import DeleteIcon from '@material-ui/icons/Delete';
import Modal from '@material-ui/core/Modal';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

class GroomingSessionsList extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      sessions: [],
      openDeleteModal: false,
      sessionToDelete: null,
    }

    this.modalStyle = {
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      width: 300,
      backgroundColor: 'white',
      padding: 12,
    }
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

  deleteGroomingSession(sessionId, completion = () => null) {
    axios.delete(`/groomingSessions/${sessionId}`, { cancelToken: this.source.token })
    .then(() => {
      const sessions = this.state.sessions.filter(session => session.id != sessionId);
      this.setState({
        sessions,
        openDeleteModal: false,
      });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      console.error(error);
    })
    .finally(() => {
      completion()
    });
  }

  handleDeleteModalOpen(session) {
    this.setState({
      openDeleteModal: true,
      sessionToDelete: session,
    });
  }

  handleDeleteModalClose(isDeletedConfirmed) {
    if (isDeletedConfirmed !== true) {
      this.setState({
        openDeleteModal: false,
        sessionsToDelete: null,
      });
      return;
    }

    this.deleteGroomingSession(this.state.sessionToDelete.id);
  }

  render() {
    return (
      <List style={{ width: '100%', maxWidth: 360 }}>
        {this.state.sessions.map((session) =>
          <SessionItem key={`session_${session.id}`}
            session={session}
            deleteCallback={(session) => this.handleDeleteModalOpen(session)}
          />
        )}
        <Modal
          open={this.state.openDeleteModal}
          onClose={() => this.handleDeleteModalClose}
        >
          <div style={this.modalStyle}>
            <Typography variant="title">Confirmer la suppression</Typography>
            <Typography variant="subheading">
              {this.state.sessionToDelete &&
                `Supprimer le Grooming ${this.state.sessionToDelete.name} ?`
              }
            </Typography>
            <Button onClick={() => this.handleDeleteModalClose(true)}>Supprimer</Button>
            <Button onClick={() => this.handleDeleteModalClose()}>Annuler</Button>
          </div>
        </Modal>
      </List>
    );
  }
}

const SessionItem = ({ session, deleteCallback }) => {
  return (
    <ListItem button>
      <ListItemText primary={session.name} />
      <ListItemSecondaryAction>
        <IconButton>
          <DeleteIcon onClick={() => deleteCallback(session)} />
        </IconButton>
      </ListItemSecondaryAction>
    </ListItem>
  );
};

export default GroomingSessionsList;
