import React from 'react';
import ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionForm from '../../components/GroomingSessionForm';
import axios from 'axios';
import Enzyme from 'enzyme';
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import MockAdapter from 'axios-mock-adapter';
import moment from 'moment';

Enzyme.configure({ adapter: new Adapter() });

describe('Grooming Session Form', () => {

  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <GroomingSessionForm />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test('handle date change', () => {
    const wrapper = mount(
      <MemoryRouter>
        <GroomingSessionForm />
      </MemoryRouter>
    );
    const groomingSessionForm = wrapper.find(GroomingSessionForm).instance();
    const currentGroomingSessionFormattedDate = moment(groomingSessionForm.state.currentGroomingSession.date).format('YYYY-MM-DD');
    expect(currentGroomingSessionFormattedDate).toEqual(moment().format('YYYY-MM-DD'));

    const date = moment('23-04-2018', 'YYYY-MM-DD');
    wrapper.find('input#groomingSessionDate').simulate('change', { target: { value: date.format('YYYY-MM-DD') } });
    const newGroomingSessionFormattedDate = moment(groomingSessionForm.state.currentGroomingSession.date).format('YYYY-MM-DD');
    expect(newGroomingSessionFormattedDate).toEqual(date.format('YYYY-MM-DD'));
  });

  test('post the form', (done) => {
    const groomingSessionForm = wrapper.find(GroomingSessionForm).instance();

    const mock = new MockAdapter(axios);
    const data = { id: '123', name: 'Posted Grooming Session', date: `${new Date()}` };
    mock.onPost('/groomingSessions').reply(201, data);

    groomingSessionForm.submit(() => {
      expect(groomingSessionForm.state.newGroomingSession).toEqual(data);
      wrapper.update();
      expect(wrapper.find('p#newGroomingSessionInfo>strong').text()).toEqual(data.name);
      done();
    });
  });
});
