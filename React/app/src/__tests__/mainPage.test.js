import React from 'react';
import { mount } from 'enzyme';
import Enzyme from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom';
import Index from '../index.js';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

describe('Given I\'m on Steam Scrum main page', () => {
  Enzyme.configure({ adapter: new Adapter() });
  const mock = new MockAdapter(axios);
  let wrapper;

  const buttonPosition = {
    addGroomingSession: 0,
    askFlorian: 1,
  };

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <Index />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });


  describe('When no sessions are available', () => {
    mock.onGet('/groomingSessions').reply(200, []);

    test('Then I see the first button to create a new Grooming Session', () => {
      const title = 'Create Grooming Session';
      const addGroomingSessionButton = wrapper.find(Button).at(buttonPosition.addGroomingSession);
      expect(addGroomingSessionButton.text()).toEqual(title);
    });

    test('Then I see the second button to ask Florian', () => {
      const title = 'Ask Florian!';
      const askFlorianButton = wrapper.find(Button).at(buttonPosition.askFlorian);
      expect(askFlorianButton.text()).toEqual(title);
    });

    test('Then I see the title "There is no Grooming Sessions available yet. Go create some!"', () => {
      wrapper.update();
      const title = 'There is no Grooming Sessions available yet. Go create some!';
      const titleTypography = wrapper.find(Typography).filterWhere((typo) => typo.text() === title);
      expect(titleTypography.length).toBe(1);
    });
  });

  describe('When sessions are available', () => {
    beforeEach(() => {
      const data = [{ id: 1, name: 'test1', date: '2018-07-01T06:00:00' }, { id: 2, name: 'test2', date: '2018-07-01T06:00:00' }];
      mock.onGet('/groomingSessions').reply(200, data);

      wrapper.unmount();
      wrapper.mount();
    });

    test('Then I see the title "Choose a Grooming Session"', () => {
      wrapper.update();
      const title = 'Choose a Grooming Session';
      const titleTypography = wrapper.find(Typography).at(0);
      expect(titleTypography.text()).toEqual(title);
    });
  });

  describe('When I click on "Create Grooming Session" Button', () => {
    test('Then a new page will open to edit a new Grooming Session', () => {
      const addGroomingSessionButton = wrapper.find(Button).at(buttonPosition.addGroomingSession);
      const parentHref = addGroomingSessionButton.parent().prop('href');
      expect(parentHref).toEqual('/groomingSessionForm');
    });
  });

  describe('When I click on "Ask Florian" Button', () => {
    test('Then a new page will open to Florian random sentence', () => {
      const askFlorianButton = wrapper.find(Button).at(buttonPosition.askFlorian);
      const parentHref = askFlorianButton.parent().prop('href');
      expect(parentHref).toEqual('/florian');
    });
  });
});
