import React from 'react'
import Grid from '@material-ui/core/Grid'
import Typography from '@material-ui/core/Typography'
import Button from '@material-ui/core/Button'
import GroomingSessionsList from './GroomingSessionsList'
import { Link } from 'react-router-dom'

class MainPage extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      sessionsCount: 0
    }
    this.countPromise = Promise.resolve()
  }

  handleCountPromise (countPromise) {
    this.countPromise = countPromise
    this.countPromise.then((count) => {
      return this.setState({ sessionsCount: count })
    })
  }

  render () {
    let title = 'There is no Grooming Sessions available yet. Go create some!'
    if (this.state.sessionsCount > 0) {
      title = 'Choose a Grooming Session'
    }

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='title' component='h2'>{title}</Typography>
        </Grid>
        <GroomingSessionsList countCallback={(promise) => this.handleCountPromise(promise)} />
        <Grid item>
          <Link to='/groomingSessionForm'>
            <Button variant='raised' color='primary'>
              Create Grooming Session
            </Button>
          </Link>
        </Grid>
        <Grid>
          <Link to='/florian'>
            <Button variant='raised' color='secondary'>
              Ask Florian!
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default MainPage
