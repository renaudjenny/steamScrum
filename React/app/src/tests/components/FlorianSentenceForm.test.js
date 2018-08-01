import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import FlorianSentenceForm from '../../components/FlorianSentenceForm';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <FlorianSentenceForm />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
