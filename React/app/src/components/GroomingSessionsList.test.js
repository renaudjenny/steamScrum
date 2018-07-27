import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import GroomingSessionsList from './GroomingSessionsList'

Enzyme.configure({ adapter: new Adapter() });

describe('Grooming sessions list', () => {
  it('renders without crashing', () => {
    const wrapper = mount(
      <MemoryRouter>
        <GroomingSessionsList />
      </MemoryRouter>
    );
    wrapper.unmount();
  });

  it('retrieve grooming sessions', (done) => {
    const wrapper = mount(
      <MemoryRouter>
        <GroomingSessionsList />
      </MemoryRouter>
    );
    const groomingSessionsList = wrapper.find(GroomingSessionsList).instance();
    expect(groomingSessionsList.state.sessions.length).toEqual(0);

    const mock = new MockAdapter(axios);
    const data = [{ id: 1, name: 'test1', date: '2018-07-01T06:00:00' }, { id: 2, name: 'test2', date: '2018-07-01T06:00:00' }];
    mock.onGet('/groomingSessions').reply(200, data);

    groomingSessionsList.refreshGroomingSessions(() => {
      expect(groomingSessionsList.state.sessions.length).toEqual(2);
      wrapper.unmount();
      done();
    });
  });
});
