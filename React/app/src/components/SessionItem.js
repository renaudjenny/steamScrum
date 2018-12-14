import React from 'react'
import ListItem from '@material-ui/core/ListItem'
import ListItemText from '@material-ui/core/ListItemText'
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction'
import IconButton from '@material-ui/core/IconButton'
import DeleteIcon from '@material-ui/icons/Delete'

class SessionItem extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      session: props.session,
      deleteCallback: props.deleteCallback
    }
  }

  handleSessionClick (sessionId) {
    this.props.history.push({
      pathname: '/GroomingSessionDetail',
      state: { sessionId: sessionId }
    })
  }

  render () {
    return (
      <ListItem button onClick={() => this.handleSessionClick(this.state.session.id)}>
        <ListItemText primary={this.state.session.name} />
        <ListItemSecondaryAction>
          <IconButton>
            <DeleteIcon onClick={() => this.state.deleteCallback(this.state.session)} />
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
}

export default SessionItem
