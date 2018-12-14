import React from 'react'
import { withRouter } from 'react-router-dom'
import Typography from '@material-ui/core/Typography'
import Grid from '@material-ui/core/Grid'
import TextField from '@material-ui/core/TextField'
import Button from '@material-ui/core/Button'
import Chip from '@material-ui/core/Chip'
import LinearProgress from '@material-ui/core/LinearProgress'
import axios from 'axios'

class StoryForm extends React.Component {
  constructor (props) {
    super(props)
    const sessionId = props.sessionId || props.location.state.sessionId
    this.state = {
      session: { id: sessionId },
      currentStory: { name: '' },
      developerNames: [],
      newDeveloperName: '',
      isGroomingSessionDataLoading: false
    }
    this.source = null
    this.mountPromise = Promise.resolve()
  }

  componentDidMount () {
    this.source = axios.CancelToken.source()
    this.mountPromise = this.refreshGroomingSession()
  }

  componentWillUnmount () {
    this.source.cancel()
  }

  refreshGroomingSession () {
    this.setState({ isGroomingSessionDataLoading: true })
    return axios.get(`/groomingSessions/${this.state.session.id}`, { cancelToken: this.source.token })
      .then((response) => {
        return this.setState({
          session: response.data,
          isGroomingSessionDataLoading: false
        })
      })
      .catch((error) => {
        if (axios.isCancel(error)) {
          return
        }
        return this.setState({ isGroomingSessionDataLoading: false })
      })
  }

  handleStoryNameChange (event) {
    const currentStory = this.state.currentStory
    currentStory.name = event.target.value
    this.setState({ currentStory })
  }

  handleDeveloperNameChange (event) {
    const newDeveloperName = event.target.value
    this.setState({ newDeveloperName })
  }

  handleAddNewDeveloperButtonClick () {
    let developerNames = this.state.developerNames
    const newDeveloperName = this.state.newDeveloperName

    const isDeveloperNameEmpty = newDeveloperName === ''
    const isDeveloperNameAlreadyInList = developerNames.includes(newDeveloperName)
    if (isDeveloperNameEmpty || isDeveloperNameAlreadyInList) {
      return
    }

    developerNames.push(newDeveloperName)
    this.setState({ developerNames })
  }

  handleDeleteDeveloperFromList (developerName) {
    const developerNames = this.state.developerNames.filter(name => name !== developerName)
    this.setState({ developerNames })
  }

  handleSessionNameClick () {
    const state = { sessionId: this.state.session.id }
    this.props.history.push('/GroomingSessionDetail', state)
  }

  render () {
    const groomingSessionLink = () => {
      if (this.state.isGroomingSessionDataLoading) {
        return <LinearProgress />
      } else {
        return (
          <Typography onClick={() => this.handleSessionNameClick()}>
            {this.state.session.name}
          </Typography>
        )
      }
    }

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='headline' component='h3'>Add a new Story</Typography>
        </Grid>
        <Grid item>
          {groomingSessionLink()}
        </Grid>
        <Grid item>
          <TextField
            id='storyName'
            label='Story name'
            value={this.state.currentStory.name}
            onChange={event => this.handleStoryNameChange(event)}
          />
        </Grid>
        <Grid item>
          <Typography component='h3'>Developers</Typography>
        </Grid>
        <Grid item>
          <TextField
            id='developerName'
            label='Developer name'
            value={this.state.newDeveloperName}
            onChange={event => this.handleDeveloperNameChange(event)}
          />
          <Button variant='raised' color='primary' onClick={() => this.handleAddNewDeveloperButtonClick()}>Add</Button>
        </Grid>
        <Grid item>
          {this.state.developerNames.map(developerName => {
            return <Chip
              key={developerName}
              label={developerName}
              onDelete={() => this.handleDeleteDeveloperFromList(developerName)}
            />
          })}
        </Grid>
      </Grid>
    )
  }
}

export default withRouter(StoryForm)
