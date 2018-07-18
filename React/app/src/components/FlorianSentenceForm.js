import React from 'react';
import Grid from '@material-ui/core/Grid';
import FormControl from '@material-ui/core/FormControl';
import Input from '@material-ui/core/Input';
import InputLabel from '@material-ui/core/InputLabel';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import axios from 'axios';

class FlorianSentenceForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      newSentence: null,
      currentSentence: "",
      sentencesCount: 0,
      maximumSentencesCount: 0,
    }
  }

  componentDidMount() {
    this.refreshContext();
  }

  refreshContext() {
    axios.get('/florianSentencesContext')
    .then((response) => {
      const { sentencesCount, maximumSentencesCount } = response.data
      this.setState({ sentencesCount: sentencesCount, maximumSentencesCount: maximumSentencesCount })
    })
    .catch((error) => {
      console.error(error);
    });
  }

  handleSentenceChange(event) {
    this.setState({ currentSentence: event.target.value })
  }

  submit() {
    axios.post('/florianSentences', { "sentence": this.state.currentSentence })
    .then((response) => {
      this.setState({ newSentence: response.data.sentence });
      this.refreshContext();
    })
    .catch((error) => {
      this.setState({ sentence: "Error" });
    });
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Ajouter une nouvelle phrase que dirait Florian</Typography>
        </Grid>
        <Grid item>
          <Typography component="p">
            Nombres de phrases déjà enregistrées <strong>{this.state.sentencesCount}/{this.state.maximumSentencesCount}</strong>
          </Typography>
        </Grid>
        <Grid item>
          <FormControl>
            <InputLabel htmlFor="sentence">Une phrase de Florian</InputLabel>
            <Input id="sentence" value={this.state.currentSentence} onChange={(event) => this.handleSentenceChange(event)} />
            <Button variant="raised" color="primary" onClick={() => this.submit()}>Ajouter</Button>
          </FormControl>
        </Grid>
        {this.state.newSentence !== null &&
          <Grid item>
            <Typography componenent="p">Votre nouvelle phrase: <strong>{this.state.newSentence}</strong> a bien été enregistrée</Typography>
          </Grid>
        }
        <Grid item>
          <Link to='/florian'>
            <Button variant="raised" color="secondary">
              Poser une autre question à Florian
            </Button>
          </Link>
        </Grid>
        <Grid item>
          <Link to='/florianSentencesList'>
            <Typography component="a">Toutes les phrases de Florian</Typography>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default FlorianSentenceForm;
