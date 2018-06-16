import React from 'react';
import Grid from '@material-ui/core/Grid';
import { Link } from 'react-router-dom';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import AutorenewIcon from '@material-ui/icons/Autorenew';
import axios from 'axios';

class FlorianRandomSentence extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sentence: ""
    }
  }

  componentDidMount() {
    this.refreshSentence()
  }

  refreshSentence() {
    axios.get('/randomFlorianSentence')
    .then((response) => {
      this.setState({ sentence: response.data.sentence });
    })
    .catch((error) => {
      this.setState({ sentence: "Error" });
    });
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <div className='bubble'>
            <Typography variant="headline" component="h3" style={{ color: '#505050' }}>
              {this.state.sentence}
            </Typography>
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
