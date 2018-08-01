import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import FlorianSentenceForm from '../../components/FlorianSentenceForm';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

Enzyme.configure({ adapter: new Adapter() });

describe('Florian Sentence Form', () => {

  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianSentenceForm />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test('renders without crashing', () => {
    wrapper.update();
  });
});
