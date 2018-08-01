import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import FlorianSentencesList from '../../components/FlorianSentencesList';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <FlorianSentencesList />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
