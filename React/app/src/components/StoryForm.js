import React from "react";
import Typography from "@material-ui/core/Typography";
import Grid from "@material-ui/core/Grid";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";
import Chip from "@material-ui/core/Chip";

class StoryForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentStory: { name: '' },
      developerNames: [],
      newDeveloperName: '',
    }
  }

  handleStoryNameChange(event) {
    const currentStory = this.state.currentStory;
    currentStory.name = event.target.value;
    this.setState({ currentStory });
  }

  handleDeveloperNameChange(event) {
    const newDeveloperName = event.target.value;
    this.setState({ newDeveloperName });
  }

  handleAddNewDeveloperButtonClick() {
    let developerNames = this.state.developerNames;
    const newDeveloperName = this.state.newDeveloperName;

    const isDeveloperNameEmpty = newDeveloperName === "";
    const isDeveloperNameAlreadyInList = developerNames.includes(newDeveloperName);
    if (isDeveloperNameEmpty || isDeveloperNameAlreadyInList) {
      return;
    }

    developerNames.push(newDeveloperName);
    this.setState({ developerNames });
  }

  handleDeleteDeveloperFromList(developerName) {
    const developerNames = this.state.developerNames.filter(name => name !== developerName);
    this.setState({ developerNames });
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
            value={this.state.newDeveloperName}
            onChange={event => this.handleDeveloperNameChange(event)}
          />
          <Button variant="raised" color="primary" onClick={() => this.handleAddNewDeveloperButtonClick()}>Add</Button>
        </Grid>
        <Grid item>
          {this.state.developerNames.map(developerName => {
            return <Chip
              key={developerName}
              label={developerName}
              onDelete={() => this.handleDeleteDeveloperFromList(developerName)}
            />
          })}
        </Grid>
      </Grid>
    );
  }
}

export default StoryForm;
