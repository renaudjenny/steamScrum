import React from 'react';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import FlorianSentence from "./FlorianSentence";

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

export default FlorianSentencesList;
