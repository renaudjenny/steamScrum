import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import FlorianRandomSentence from './FlorianRandomSentence';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <FlorianRandomSentence />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
