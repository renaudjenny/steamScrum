import React from 'react';
import Grid from '@material-ui/core/Grid';
import FormControl from '@material-ui/core/FormControl';
import Input from '@material-ui/core/Input';
import InputLabel from '@material-ui/core/InputLabel';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import axios from 'axios';

class FlorianSentenceEdit extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      florianSentence: props.location.state.florianSentence,
      originalSentence: props.location.state.florianSentence.sentence
    }
  }

  handleSentenceChange(event) {
    const newFlorianSentence = this.state.florianSentence;
    newFlorianSentence.sentence = event.target.value;
    this.setState({ florianSentence: newFlorianSentence })
  }

  save() {
    axios.patch(`florianSentences/${this.state.florianSentence.id}`, {
      sentence: this.state.florianSentence.sentence,
    }).then((result) => {
      this.props.history.push('/florianSentencesList')
    })
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
	  <Typography component="h3">Éditer la phrase : <strong>{this.state.originalSentence}</strong></Typography>
        </Grid>
        <Grid item>
          <FormControl>
            <InputLabel htmlFor="sentence">La phrase a édité</InputLabel>
            <Input id="sentence" value={this.state.florianSentence.sentence} onChange={(event) => this.handleSentenceChange(event)} multiline='true' />
            <Button variant="raised" color="primary" onClick={() => this.save()}>Enregistrer</Button>
          </FormControl>
        </Grid>
      </Grid>
    )
  }

}

export default FlorianSentenceEdit;
