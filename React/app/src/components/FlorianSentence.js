import React from 'react';
import { withRouter } from "react-router-dom";
import axios from 'axios';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import IconButton from '@material-ui/core/IconButton';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';
import Modal from '@material-ui/core/Modal';

class FlorianSentence extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      florianSentence: props.value,
      openDeleteModal: false,
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

  handleSentenceClick() {
    this.props.history.push('/florianSentenceEdit', { florianSentence: this.state.florianSentence });
  }

  handleDeleteModalOpen() {
    this.setState({ openDeleteModal: true })
  }

  handleDeleteModalClose(isDeleteConfirmed) {
    if (isDeleteConfirmed !== true) {
      this.setState({ openDeleteModal: false });
      return;
    }

    axios.delete(`florianSentences/${this.state.florianSentence.id}`)
    .then(() => {
      this.setState({ openDeleteModal: false });
      this.props.onDelete(this.state.florianSentence.id);
    });
  }

  render() {
    return (
      <ListItem button onClick={() => this.handleSentenceClick()}>
        <ListItemIcon>
          <EditIcon />
        </ListItemIcon>
        <ListItemText primary={this.state.florianSentence.sentence} />
        <ListItemSecondaryAction>
          <IconButton>
            <DeleteIcon onClick={() => { this.handleDeleteModalOpen() }} />
            <Modal
              open={this.state.openDeleteModal}
              onClose={() => this.handleDeleteModalClose()}
            >
              <div style={this.modalStyle}>
                <Typography variant="title">Confirmer la suppression</Typography>
                <Typography variant="subheading">
                  {`Supprimer la phrase ${this.state.florianSentence.sentence} ?`}
                </Typography>
                <Button onClick={() => this.handleDeleteModalClose(true)}>Supprimer</Button>
                <Button onClick={() => this.handleDeleteModalClose()}>Annuler</Button>
              </div>
            </Modal>
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
}

export default withRouter(FlorianSentence);
