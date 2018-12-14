import React from 'react'
import Grid from '@material-ui/core/Grid'
import FormControl from '@material-ui/core/FormControl'
import Input from '@material-ui/core/Input'
import InputLabel from '@material-ui/core/InputLabel'
import { Link } from 'react-router-dom'
import Button from '@material-ui/core/Button'
import Typography from '@material-ui/core/Typography'
import LinearProgress from '@material-ui/core/LinearProgress'
import axios from 'axios'

class FlorianSentenceForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      newSentence: null,
      currentSentence: '',
      sentencesCount: 0,
      maximumSentencesCount: 0,
      isFlorianSentenceDataLoading: false
    }
    this.mountPromise = Promise.resolve()
  }

  componentDidMount () {
    this.source = axios.CancelToken.source()
    this.mountPromise = this.refreshContext()
  }

  componentWillUnmount () {
    this.source.cancel()
  }

  refreshContext () {
    this.setState({ isFlorianSentenceDataLoading: true })
    return axios.get('/florianSentencesContext', { cancelToken: this.source.token })
      .then((response) => {
        const { sentencesCount, maximumSentencesCount } = response.data
        return this.setState({
          sentencesCount: sentencesCount,
          maximumSentencesCount: maximumSentencesCount,
          isFlorianSentenceDataLoading: false
        })
      })
      .catch((error) => {
        if (axios.isCancel(error)) {
          return
        }
        return this.setState({ isFlorianSentenceDataLoading: false })
      })
  }

  handleSentenceChange (event) {
    this.setState({ currentSentence: event.target.value })
  }

  submit () {
    axios.post('/florianSentences', { 'sentence': this.state.currentSentence })
      .then((response) => {
        this.setState({ newSentence: response.data.sentence })
        this.refreshContext()
      })
      .catch(() => {
        this.setState({ sentence: 'Error' })
      })
  }

  render () {
    const florianDataContent = () => {
      if (this.state.isFlorianSentenceDataLoading) {
        return <LinearProgress style={{ width: 300 }} />
      } else {
        return <Typography component='p'>
            Already saved sentences: <strong>{this.state.sentencesCount}/{this.state.maximumSentencesCount}</strong>
        </Typography>
      }
    }

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant='headline' component='h3'>Ajouter une nouvelle phrase que dirait Florian</Typography>
        </Grid>
        <Grid item>
          {florianDataContent()}
        </Grid>
        <Grid item>
          <FormControl>
            <InputLabel htmlFor='sentence'>Une phrase de Florian</InputLabel>
            <Input id='sentence' value={this.state.currentSentence} onChange={(event) => this.handleSentenceChange(event)} />
            <Button variant='raised' color='primary' onClick={() => this.submit()}>Ajouter</Button>
          </FormControl>
        </Grid>
        {this.state.newSentence !== null &&
          <Grid item>
            <Typography componenent='p'>Votre nouvelle phrase: <strong>{this.state.newSentence}</strong> a bien été enregistrée</Typography>
          </Grid>
        }
        <Grid item>
          <Link to='/florian'>
            <Button variant='raised' color='secondary'>
              Poser une autre question à Florian
            </Button>
          </Link>
        </Grid>
        <Grid item>
          <Link to='/florianSentencesList'>
            <Typography>Toutes les phrases de Florian</Typography>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default FlorianSentenceForm
