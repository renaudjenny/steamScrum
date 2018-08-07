import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import GroomingSessionsList from '../../components/GroomingSessionsList'

Enzyme.configure({ adapter: new Adapter() });

describe('Grooming Sessions List', () => {

  let wrapper;
  let groomingSessionsList;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <GroomingSessionsList.WrappedComponent />
      </MemoryRouter>
    );
    groomingSessionsList = wrapper.find(GroomingSessionsList.WrappedComponent).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test('retrieve grooming sessions', (done) => {
    expect(groomingSessionsList.state.sessions.length).toEqual(0);

    const mock = new MockAdapter(axios);
    const data = [{ id: 1, name: 'test1', date: '2018-07-01T06:00:00' }, { id: 2, name: 'test2', date: '2018-07-01T06:00:00' }];
    mock.onGet('/groomingSessions').reply(200, data);

    groomingSessionsList.refreshGroomingSessions(() => {
      expect(groomingSessionsList.state.sessions.length).toEqual(2);
      done();
    });
  });

  test('delete a session', (done) => {
    const sessions = [{ id: '123', name: 'test delete', date: '2018-07-01T06:00:00' }];
    groomingSessionsList.setState({ sessions });
    expect(groomingSessionsList.state.sessions.length).toEqual(1);

    const mock = new MockAdapter(axios);
    mock.onDelete(`/groomingSessions/${sessions[0].id}`).reply(200);

    groomingSessionsList.deleteGroomingSession(sessions[0].id, () => {
      expect(groomingSessionsList.state.sessions.length).toEqual(0);
      done();
    });
  });
});
