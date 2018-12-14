import React from 'react'
import axios from 'axios'
import Grid from '@material-ui/core/Grid'
import List from '@material-ui/core/List'
import { Link } from 'react-router-dom'
import Button from '@material-ui/core/Button'
import Typography from '@material-ui/core/Typography'
import FlorianSentence from './FlorianSentence'
import Modal from '@material-ui/core/Modal'

class FlorianSentencesList extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      sentences: [],
      currentSentence: '',
      sentencesCount: 0,
      maximumSentencesCount: 0,
      sentenceToDelete: null,
      openDeleteModal: false
    }
    this.mountPromise = Promise.resolve()
    this.deletePromise = Promise.resolve()

    this.modalStyle = {
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      width: 300,
      backgroundColor: 'white',
      padding: 12
    }
  }

  componentDidMount () {
    this.source = axios.CancelToken.source()
    this.mountPromise = this.refreshSentences()
      .then(() => {
        return this.refreshContext()
      })
  }

  componentWillUnmount () {
    this.source.cancel()
  }

  refreshSentences () {
    return axios.get('/florianSentences', { cancelToken: this.source.token })
      .then((response) => {
        return this.setState({ sentences: response.data })
      })
      .catch((error) => {
        if (axios.isCancel(error)) {

        }
      })
  }

  refreshContext () {
    return axios.get('/florianSentencesContext')
      .then((response) => {
        const { sentencesCount, maximumSentencesCount } = response.data
        return this.setState({ sentencesCount: sentencesCount, maximumSentencesCount: maximumSentencesCount })
      })
      .catch((error) => {
        if (axios.isCancel(error)) {

        }
      })
  }

  deleteFlorianSentence (id) {
    return axios.delete(`florianSentences/${id}`)
      .then(() => {
        const sentences = this.state.sentences.filter(sentence => sentence.id !== id)
        this.setState({
          openDeleteModal: false,
          sentences: sentences
        })
        return this.refreshContext()
      })
      .catch((error) => {
        if (axios.isCancel(error)) {

        }
      })
  }

  handleDeleteModalOpen (sentence) {
    this.setState({
      openDeleteModal: true,
      sentenceToDelete: sentence
    })
  }

  handleDeleteModalClose (isDeleteConfirmed) {
    if (isDeleteConfirmed !== true) {
      this.setState({
        openDeleteModal: false,
        sentenceToDelete: null
      })
      this.deletePromise = Promise.resolve()
      return
    }
    this.deletePromise = this.deleteFlorianSentence(this.state.sentenceToDelete.id)
  }

  render () {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='headline' component='h3'>Toutes les phrases de Florian</Typography>
        </Grid>
        <Grid item>
          <Typography component='p'>
            Already saved sentences: <strong>{this.state.sentencesCount}/{this.state.maximumSentencesCount}</strong>
          </Typography>
        </Grid>
        <List style={{ width: '100%', maxWidth: 360 }}>
          {this.state.sentences.map(sentence =>
            <FlorianSentence
              key={`sentence${sentence.id}`}
              value={sentence}
              deleteCallback={sentence => this.handleDeleteModalOpen(sentence)}
              history={this.props.history}
            />
          )}
          <Modal
            open={this.state.openDeleteModal}
            onClose={() => this.handleDeleteModalClose()}
          >
            <div style={this.modalStyle}>
              <Typography variant='title'>Confirm deletion?</Typography>
              <Typography variant='subheading'>
                {this.state.sentenceToDelete &&
                  `Remove sentence: ${this.state.sentenceToDelete.sentence}?`
                }
              </Typography>
              <Button onClick={() => this.handleDeleteModalClose(true)}>Remove</Button>
              <Button onClick={() => this.handleDeleteModalClose()}>Cancel</Button>
            </div>
          </Modal>
        </List>
        <Grid item>
          <Link to='/florian'>
            <Button variant='raised' color='secondary'>
              Poser une autre question à Florian
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default FlorianSentencesList
