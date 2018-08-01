import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom';
import axios from 'axios';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import MockAdapter from 'axios-mock-adapter';
import FlorianRandomSentence from '../../components/FlorianRandomSentence';

Enzyme.configure({ adapter: new Adapter() });

describe('Florian Random sentence', () => {

  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianRandomSentence />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test('search for a new random sentence', (done) => {
    const wrapper = mount(
      <MemoryRouter>
        <FlorianRandomSentence />
      </MemoryRouter>
    );
    const florianRandomSentence = wrapper.find(FlorianRandomSentence).instance();

    const mock = new MockAdapter(axios);
    const data = { sentence: "a random sentence from test" };
    mock.onGet('/randomFlorianSentence').reply(200, data);

    florianRandomSentence.refreshSentence(() => {
      expect(florianRandomSentence.state.sentence).toEqual(data.sentence);
      wrapper.unmount();
      done();
    });
  });
});
