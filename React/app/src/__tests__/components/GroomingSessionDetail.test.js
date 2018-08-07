import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import axios from 'axios';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import MockAdapter from 'axios-mock-adapter';
import GroomingSessionDetail from '../../components/GroomingSessionDetail';

Enzyme.configure({ adapter: new Adapter() });

describe('Grooming Session Detail', () => {

  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <GroomingSessionDetail sessionId={123} />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test('retrieve grooming session', (done) => {
    const groomingSessionDetail = wrapper.find(GroomingSessionDetail).instance();
    
    expect(groomingSessionDetail.state.session.id).toEqual(123);
    expect(groomingSessionDetail.state.session.name).toBeUndefined();

    const mock = new MockAdapter(axios);
    const data = { id: 123, name: "Session test 123", date: "2018-08-03T05:37:13Z", userStories: [] };
    mock.onGet('/groomingSessions/123').reply(200, data);

    groomingSessionDetail.refreshGroomingSession(() => {
      expect(groomingSessionDetail.state.session.id).toEqual(123);
      expect(groomingSessionDetail.state.session.name).toEqual("Session test 123");
      done();
    });
  });
});
