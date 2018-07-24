import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionForm from './GroomingSessionForm';
import axios from 'axios';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import MockAdapter from 'axios-mock-adapter';

Enzyme.configure({ adapter: new Adapter() });

it('renders without crashing', () => {
  const wrapper = mount(
    <MemoryRouter>
      <GroomingSessionForm />
    </MemoryRouter>
  );
  wrapper.unmount();
});

it('retrieve Grooming Sessions context', (done) => {
  const wrapper = mount(
    <MemoryRouter>
      <GroomingSessionForm />
    </MemoryRouter>
  );
  const groomingSessionForm = wrapper.find(GroomingSessionForm).instance();

  const mock = new MockAdapter(axios);
  const data = { groomingSessionsCount: 5, maximumGroomingSessionsCount: 98 };
  mock.onGet('/groomingSessionsContext').reply(200, data);

  groomingSessionForm.refreshContext(() => {
    expect(groomingSessionForm.state.groomingSessionsCount).toEqual(data.groomingSessionsCount);
    expect(groomingSessionForm.state.maximumGroomingSessionsCount).toEqual(data.maximumGroomingSessionsCount);
    wrapper.unmount();
    done();
  });
});

it('post the form', (done) => {
  const wrapper = mount(
    <MemoryRouter>
      <GroomingSessionForm />
    </MemoryRouter>
  );
  const groomingSessionForm = wrapper.find(GroomingSessionForm).instance();

  const mock = new MockAdapter(axios);
  const data = { groomingSession: { id: '123', name: 'Posted Grooming Session', date: `${new Date()}` } };
  mock.onPost('/groomingSessions').reply(201, data);

  groomingSessionForm.submit(() => {
    expect(groomingSessionForm.state.newGroomingSession).toEqual(data.groomingSession);
    wrapper.unmount();
    done();
  });
});
