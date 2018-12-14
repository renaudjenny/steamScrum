import React from 'react'
import { withRouter } from 'react-router-dom'
import ListItem from '@material-ui/core/ListItem'
import ListItemIcon from '@material-ui/core/ListItemIcon'
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction'
import ListItemText from '@material-ui/core/ListItemText'
import IconButton from '@material-ui/core/IconButton'
import EditIcon from '@material-ui/icons/Edit'
import DeleteIcon from '@material-ui/icons/Delete'

class FlorianSentence extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      florianSentence: props.value,
      deleteCallback: props.deleteCallback
    }
  }

  handleSentenceClick () {
    this.props.history.push('/florianSentenceEdit', { florianSentence: this.state.florianSentence })
  }

  render () {
    return (
      <ListItem button onClick={() => this.handleSentenceClick()}>
        <ListItemIcon>
          <EditIcon />
        </ListItemIcon>
        <ListItemText primary={this.state.florianSentence.sentence} />
        <ListItemSecondaryAction>
          <IconButton>
            <DeleteIcon onClick={() => this.state.deleteCallback(this.state.florianSentence)} />
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
}

export default withRouter(FlorianSentence)
