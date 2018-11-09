import React from 'react';
import { mount } from 'enzyme';
import Enzyme from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom';
import MainPage from '../components/MainPage';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import GroomingSessionsList from "../components/GroomingSessionsList";
import SessionItem from "../components/SessionItem";
import Modal from '@material-ui/core/Modal';
import DeleteIcon from '@material-ui/icons/Delete';
import ListItemText from '@material-ui/core/ListItemText';

describe('Given I\'m on Steam Scrum main page', () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let mainPage;
  let groomingSessionsList;

  const typoPosition = {
    title: 0,
  };

  const buttonPosition = {
    addGroomingSession: 0,
    askFlorian: 1,
  };

  const confirmDeleteItemModalButtonPosition = {
    confirm: 0,
    cancel: 1
  };

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <MainPage />
      </MemoryRouter>
    );
    mainPage = wrapper.find(MainPage).instance();
    groomingSessionsList = wrapper.find(GroomingSessionsList.WrappedComponent).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });


  describe('When no sessions are available', () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      mock.onGet('/groomingSessions').reply(200, []);
    });

    test('Then I see the first button to create a new Grooming Session', () => {
      const addGroomingSessionButton = wrapper.find(Button).at(buttonPosition.addGroomingSession);
      expect(addGroomingSessionButton.text()).toEqual('Create Grooming Session');
    });

    test('Then I see the second button to ask Florian', () => {
      const askFlorianButton = wrapper.find(Button).at(buttonPosition.askFlorian);
      expect(askFlorianButton.text()).toEqual('Ask Florian!');
    });

    test('Then I see the title "There is no Grooming Sessions available yet. Go create some!"', () => {
      const typo = wrapper.find(Typography).at(typoPosition.title);
      expect(typo.text()).toBe("There is no Grooming Sessions available yet. Go create some!");
    });
  });

  describe('When sessions are available', () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = [
        { id: 1, name: 'test1', date: '2018-07-01T06:00:00' },
        { id: 2, name: 'test2', date: '2018-07-01T06:00:00' }
      ];
      mock.onGet('/groomingSessions').reply(200, data);
    });

    test('Then I see the title "Choose a Grooming Session"', () => {
      expect.assertions(1);
      return mainPage.countPromise.then(() => {
        wrapper.update();
        const textTypography = wrapper.find(Typography).at(typoPosition.title)
        expect(textTypography.text()).toBe("Choose a Grooming Session");
      });
    });
    
    test("Then I see a list of Grooming Sessions", () => {
      expect.assertions(1);
      return groomingSessionsList.mountPromise.then(() => {
        wrapper.update();
        const groomingSessionItems = wrapper.find(SessionItem);
        expect(groomingSessionItems).toHaveLength(2);
      });
    });
  });

  describe("When I want to delete a Grooming Session", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = [
        { id: 1, name: 'test1', date: '2018-07-01T06:00:00' },
        { id: 2, name: 'test2', date: '2018-07-01T06:00:00' }
      ];
      mock.onGet('/groomingSessions').reply(200, data);
      mock.onDelete('/groomingSessions/1').reply(200);
    });

    test("Then I'm asked to confirm the deletion", () => {
      expect.assertions(2);
      return groomingSessionsList.mountPromise.then(() => {
        wrapper.update();
        const findModalOpenState = () => wrapper.find(Modal).props().open;

        expect(findModalOpenState()).toBe(false);

        const firstSessionItem = wrapper.find(SessionItem).at(0);
        const deleteButton = firstSessionItem.find(DeleteIcon);

        deleteButton.props().onClick();
        wrapper.update();
        expect(findModalOpenState()).toBe(true);
      });
    });

    test("Then I confirm the deletion and Item is removed", () => {
      const findGroomingSessionItems = () => wrapper.find(SessionItem);

      expect.assertions(3);
      return groomingSessionsList.mountPromise
      .then(() => {
        wrapper.update();
        expect(findGroomingSessionItems()).toHaveLength(2);

        const firstSessionItem = wrapper.find(SessionItem).at(0);
        const deleteButton = firstSessionItem.find(DeleteIcon);

        deleteButton.props().onClick();
        wrapper.update();

        const modal = wrapper.find(Modal);
        const confirmButton = modal.find(Button).at(confirmDeleteItemModalButtonPosition.confirm);
        confirmButton.props().onClick();
        return groomingSessionsList.deletePromise
      })
      .then(() => {
        wrapper.update();
        expect(findGroomingSessionItems()).toHaveLength(1);
        const sessionItem = findGroomingSessionItems().at(0);
        const itemText = sessionItem.find(ListItemText);
        expect(itemText.props().primary).toBe('test2');
      });
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
