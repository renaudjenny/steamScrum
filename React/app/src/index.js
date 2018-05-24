import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import axios from 'axios';

function Square(props) {
  return (
    <button className="square" onClick={props.onClick}>
      {props.value}
    </button>
  );
}

class Board extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      squares: Array(9).fill(null),
      xIsNext: true,
    };
  }

  handleClick(i) {
    const squares = this.state.squares.slice();
    squares[i] = this.state.xIsNext ? 'X' : 'O';
    this.setState({
      squares: squares,
      xIsNext: !this.state.xIsNext,
    });
  }

  renderSquare(i) {
    return <Square
      value={this.state.squares[i]}
      onClick={() => this.handleClick(i)}
    />;
  }

  render() {
    const status = 'Next player: ' + (this.state.xIsNext ? 'X' : 'O');

    return (
      <div>
        <div className="status">{status}</div>
        <div className="board-row">
          {this.renderSquare(0)}
          {this.renderSquare(1)}
          {this.renderSquare(2)}
        </div>
        <div className="board-row">
          {this.renderSquare(3)}
          {this.renderSquare(4)}
          {this.renderSquare(5)}
        </div>
        <div className="board-row">
          {this.renderSquare(6)}
          {this.renderSquare(7)}
          {this.renderSquare(8)}
        </div>
      </div>
    );
  }
}

class Sessions extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      buttonNames: props.value
    }
  }

  componentDidMount() {
    axios.get('/groomingSessions')
    .then(function (response) {
      console.log({ response });
    })
    .catch(function (error) {
      console.log(error);
    });
  }

  render() {
    return (
      <div>
        {this.state.buttonNames.map((buttonName) => <SessionButton value={buttonName} />)}
      </div>
    )
  }
}

function SessionButton(props) {
  return (<button>{props.value}</button>);
}

// ========================================

ReactDOM.render(
  <Sessions value={["hello", "is", "there", "someone", "here", "?"]} />,
  document.getElementById('root')
);
