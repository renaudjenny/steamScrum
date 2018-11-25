import React from "react";
import Typography from "@material-ui/core/Typography";
import Grid from "@material-ui/core/Grid";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";

class StoryForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentStory: { name: '' },
      newDeveloper: { name: '' },
    }
  }

  handleStoryNameChange(event) {
    const currentStory = this.state.currentStory;
    currentStory.name = event.target.value;
    this.setState({ currentStory });
  }

  handleDeveloperNameChange(event) {
    const newDeveloper = this.state.newDeveloper;
    newDeveloper.name = event.target.value;
    this.setState({ newDeveloper });
  }

  render() {
    return (
      <Grid container spacing={24} direction='column' alignItems='center' justify='center'>
        <Grid item>
          <Typography variant="headline" component="h3">Add a new Story</Typography>
        </Grid>
        <Grid item>
          <TextField
            id="storyName"
            label="Story name"
            value={this.state.currentStory.name}
            onChange={event => this.handleStoryNameChange(event)}
          />
        </Grid>
        <Grid item>
          <Typography component="h3">Developers</Typography>
        </Grid>
        <Grid item>
          <TextField
            id="developerName"
            label="Developer name"
            value={this.state.newDeveloper.name}
            onChange={event => this.handleDeveloperNameChange(event)}
          />
          <Button variant="raised" color="primary">Add</Button>
        </Grid>
      </Grid>
    );
  }
}

export default StoryForm;
