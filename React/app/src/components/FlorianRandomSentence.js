import React from 'react';
import Grid from '@material-ui/core/Grid';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import AutorenewIcon from '@material-ui/icons/Autorenew';
import CircularProgress from '@material-ui/core/CircularProgress';
import axios from 'axios';

class FlorianRandomSentence extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      sentence: "",
      isLoadingSentence: false,
    }
    this.mountPromise = Promise.resolve();
  }

  componentDidMount() {
    this.source = axios.CancelToken.source();
    this.mountPromise = this.refreshSentence();
  }

  componentWillUnmount() {
    this.source.cancel();
  }

  refreshSentence() {
    this.setState({ isLoadingSentence: true });
    return axios.get('/randomFlorianSentence', { cancelToken: this.source.token })
    .then((response) => {
      return this.setState({
        isLoadingSentence: false,
        sentence: response.data.sentence
      });
    })
    .catch((error) => {
      if (axios.isCancel(error)) {
        return;
      }
      return this.setState({
        isLoadingSentence: false,
        sentence: "Error"
      });
    });
  }

  render() {
    const bubbleContent = () => {
      if (this.state.isLoadingSentence) {
        return <CircularProgress size={50} />
      } else {
        return <Typography variant="headline" component="h3" style={{ color: '#505050' }}>
          {this.state.sentence}
         </Typography>
      }
    }

    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <div className='bubble'>
            {bubbleContent()}
          </div>
        </Grid>
        <Grid item>
          <img src="/images/Florian.png" style={{ maxHeight: 300 + 'px' }} alt='Florian' />
        </Grid>
        <Grid item>
          <Button variant="fab" color="primary" aria-label="refresh" onClick={() => this.refreshSentence()}>
            <AutorenewIcon />
          </Button>
        </Grid>
        <Grid item>
          <Link to='/florianSentenceForm'>
            <Button variant="raised" color="secondary">
                Ajouter une nouvelle phrase
            </Button>
          </Link>
        </Grid>
      </Grid>
    )
  }
}

export default FlorianRandomSentence;
