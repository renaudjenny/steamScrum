import React from 'react';
import ReactDOM from 'react-dom';
import Grid from '@material-ui/core/Grid';
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
  }

  componentDidMount() {
    this.refreshSentences();
    this.refreshContext();
  }

  refreshSentences() {
    axios.get('/florianSentences')
    .then((response) => {
      this.setState({ sentences: response.data })
    })
    .catch(() => {
      this.setState({ sentences: [{ id: -1, sentence: "error1" }, { id: -2, sentence: "error2 with long text" }] })
    });
  }

  refreshContext() {
    axios.get('/florianSentencesContext')
    .then((response) => {
      const { sentencesCount, maximumSentencesCount } = response.data
      this.setState({ sentencesCount: sentencesCount, maximumSentencesCount: maximumSentencesCount })
    });
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Toutes les phrases de Florian</Typography>
        </Grid>
        <Grid item>
          <Typography component="p">
            Nombres de phrases déjà enregistrées <strong>{this.state.sentencesCount}/{this.state.maximumSentencesCount}</strong>
          </Typography>
        </Grid>
        <Grid container spacing={24} direction='column' alignItems='center' justify='space-between'>
          <Grid item>
            {this.state.sentences.map((sentence) => <FlorianSentence value={sentence} />)}
          </Grid>
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
    }
  }

  render() {
    return (
      <Grid container spacing={24} direction='row' alignItems='center' justify='center'>
        <Grid item>
          <Typography component="p">{this.state.florianSentence.sentence}</Typography>
        </Grid>
        <Grid item>
          <Link to={{ 
            pathname: '/florianSentenceEdit',
            state: { florianSentence: this.state.florianSentence } 
            }}>
            <Button variant="outlined" color="primary">Edit</Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default FlorianSentencesList;
