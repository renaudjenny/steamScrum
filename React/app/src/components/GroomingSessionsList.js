import React from 'react'
import axios from 'axios'
import List from '@material-ui/core/List'
import Modal from '@material-ui/core/Modal'
import Button from '@material-ui/core/Button'
import Typography from '@material-ui/core/Typography'
import SessionItem from './SessionItem'
import { withRouter } from 'react-router-dom'

class GroomingSessionsList extends React.Component {
  constructor (props) {
    super(props)
    const countCallback = props.countCallback || (() => null)
    this.state = {
      sessions: [],
      openDeleteModal: false,
      sessionToDelete: null,
      countCallback
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
    this.mountPromise = this.refreshGroomingSessions()
  }

  componentWillUnmount () {
    this.source.cancel()
  }

  refreshGroomingSessions () {
    return axios.get('/groomingSessions', { cancelToken: this.source.token })
      .then((response) => {
        this.setState({ sessions: response.data })
        this.state.countCallback(Promise.resolve(response.data.length))
      })
      .catch((error) => {
        if (axios.isCancel(error)) {
          return
        }
        return error
      })
  }

  deleteGroomingSession (sessionId) {
    return axios.delete(`/groomingSessions/${sessionId}`, { cancelToken: this.source.token })
      .then(() => {
        const sessions = this.state.sessions.filter(session => session.id !== sessionId)
        return this.setState({
          sessions,
          openDeleteModal: false
        })
      })
      .catch((error) => {
        if (axios.isCancel(error)) {

        }
      })
  }

  handleDeleteModalOpen (session) {
    this.setState({
      openDeleteModal: true,
      sessionToDelete: session
    })
  }

  handleDeleteModalClose (isDeletedConfirmed) {
    if (isDeletedConfirmed !== true) {
      this.setState({
        openDeleteModal: false,
        sessionsToDelete: null
      })
      this.deletePromise = Promise.resolve()
      return
    }

    this.deletePromise = this.deleteGroomingSession(this.state.sessionToDelete.id)
  }

  render () {
    return (
      <List style={{ width: '100%', maxWidth: 360 }}>
        {this.state.sessions.map((session) =>
          <SessionItem key={`session_${session.id}`}
            session={session}
            deleteCallback={(session) => this.handleDeleteModalOpen(session)}
            history={this.props.history}
          />
        )}
        <Modal
          open={this.state.openDeleteModal}
          onClose={() => this.handleDeleteModalClose}
        >
          <div style={this.modalStyle}>
            <Typography variant='title'>Confirmer la suppression</Typography>
            <Typography variant='subheading'>
              {this.state.sessionToDelete &&
                `Supprimer le Grooming ${this.state.sessionToDelete.name} ?`
              }
            </Typography>
            <Button onClick={() => this.handleDeleteModalClose(true)}>Supprimer</Button>
            <Button onClick={() => this.handleDeleteModalClose()}>Annuler</Button>
          </div>
        </Modal>
      </List>
    )
  }
}

export default withRouter(GroomingSessionsList)
