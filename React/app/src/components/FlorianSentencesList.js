import React from 'react';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import IconButton from '@material-ui/core/IconButton';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';
import Modal from '@material-ui/core/Modal';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import axios from 'axios';

class FlorianSentencesList extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      sentences: [],
      currentSentence: "",
      sentencesCount: 0,
      maximumSentencesCount: 0,
    }
    this.mountPromise = Promise.resolve();
  }

  componentDidMount() {
    this.source = axios.CancelToken.source();
    this.mountPromise =  this.refreshSentences()
    .then(() => {
      return this.refreshContext();
    });
  }

  componentWillUnmount() {
    this.source.cancel();
  }

  refreshSentences() {
    return axios.get('/florianSentences', { cancelToken: this.source.token })
    .then((response) => {
      return this.setState({ sentences: response.data })
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      return this.setState({ sentences: [{ id: -1, sentence: "error1" }, { id: -2, sentence: "error2 with long text very very very very very long" }] })
    });
  }

  refreshContext() {
    return axios.get('/florianSentencesContext')
    .then((response) => {
      const { sentencesCount, maximumSentencesCount } = response.data
      return this.setState({ sentencesCount: sentencesCount, maximumSentencesCount: maximumSentencesCount })
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      return;
    });
  }

  handleDeletedSentence(id) {
    const sentences = this.state.sentences.filter((sentence) => sentence.id !== id);
    this.setState({ sentences: sentences });
    this.refreshContext();
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Toutes les phrases de Florian</Typography>
        </Grid>
        <Grid item>
          <Typography component="p">
            Already saved sentences: <strong>{this.state.sentencesCount}/{this.state.maximumSentencesCount}</strong>
          </Typography>
        </Grid>
        <List style={{ width: '100%', maxWidth: 360 }}>
          {this.state.sentences.map((sentence) => <FlorianSentence key={`sentence${sentence.id}`} value={sentence} history={this.props.history} onDelete={(id) => this.handleDeletedSentence(id)} />)}
        </List>
        <Grid item>
          <Link to='/florian'>
            <Button variant="raised" color="secondary">
              Poser une autre question à Florian
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

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

export default FlorianSentencesList;
