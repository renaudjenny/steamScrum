import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import FlorianSentenceEdit from '../../components/FlorianSentenceEdit';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <FlorianSentenceEdit />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
