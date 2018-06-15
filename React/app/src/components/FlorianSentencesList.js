import React from 'react';
import ReactDOM from 'react-dom';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import IconButton from '@material-ui/core/IconButton';
import EditIcon from '@material-ui/icons/Edit';
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
        <List style={{ width: '100%', maxWidth: 360 }}>
          {this.state.sentences.map((sentence) => <FlorianSentence value={sentence} />)}
        </List>
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
      <ListItem>
        <ListItemText primary={this.state.florianSentence.sentence} />
        <ListItemSecondaryAction>
          <IconButton aria-label="Edit">
            <Link to={{
              pathname: '/florianSentenceEdit',
              state: { florianSentence: this.state.florianSentence }
              }}>
              <EditIcon />
            </Link>
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
}

export default FlorianSentencesList;
