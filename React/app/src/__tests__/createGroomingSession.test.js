import React from 'react';
import Enzyme from "enzyme";
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionForm from "../components/GroomingSessionForm";
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import moment from 'moment';

describe("Given I'm on the form to create a new Grooming Session", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let groomingSessionForm;

  const typoPosition = {
    title: 0,
    context: 1,
    otherSessions: 2
  };

  const textFieldPosition = {
    name: 0,
    date: 1
  };

  const buttonPosition = {
    add: 0
  };

  const typoPositionAfterAddSubmit = {
    title: 0,
    context: 1,
    newAddedSession: 2,
    otherSessions: 3
  };

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <GroomingSessionForm />
      </MemoryRouter>
    );
    groomingSessionForm = wrapper.find(GroomingSessionForm).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  describe("When I'm on the form without doing anything yet", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = {groomingSessionsCount: 0, maximumGroomingSessionsCount: 250};
      mock.onGet('/groomingSessionsContext').reply(200, data);
    });

    test("Then I see the title Add a Grooming Session", () => {
      const title = "Add a Grooming Session";
      const titleTypography = wrapper.find(Typography).at(typoPosition.title);
      expect(titleTypography.text()).toBe(title);
    });

    test("Then I see 0 Already saved Grooming Session count, with a maximum of 250 available", () => {
      expect.assertions(1);
      return groomingSessionForm.mountPromise.then(() => {
        wrapper.update();
        const textTypography = wrapper.find(Typography).at(typoPosition.context)
        expect(textTypography.text()).toBe("Already saved Grooming Sessions: 0/250");
      });
    });

    test("Then I see a text field Session name to set the name of the Grooming Session", () => {
      const field = wrapper.find(TextField).at(textFieldPosition.name);
      expect(field.text()).toBe("Session name");
    });

    test("Then I see a text field Session date to set the date of the Grooming Session", () => {
      const field = wrapper.find(TextField).at(textFieldPosition.date);
      expect(field.text()).toBe("Session date");
    });

    test("Then I see a button Add to add to validate the form", () => {
      const button = wrapper.find(Button).at(buttonPosition.add);
      expect(button.text()).toBe("Add");
    });

    test("Then I see a link Other Sessions to open the page to the Sessions list", () => {
      expect.assertions(1);
      return groomingSessionForm.mountPromise.then(() => {
        wrapper.update();
        const typo = wrapper.find(Typography).at(typoPosition.otherSessions);
        expect(typo.text()).toBe("Other Sessions");
      });
    });
  });

  describe("When there is already Grooming Sessions available. Like 5 available Grooming Sessions", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = {groomingSessionsCount: 5, maximumGroomingSessionsCount: 250};
      mock.onGet('/groomingSessionsContext').reply(200, data);
    });

    test("Then I see 5 Already saved Grooming Session count, with a maximum of 250 available", () => {
      expect.assertions(1);
      return groomingSessionForm.mountPromise.then(() => {
        wrapper.update();
        const typo = wrapper.find(Typography).at(typoPosition.context);
        expect(typo.text()).toBe("Already saved Grooming Sessions: 5/250");
      });
    });
  });

  describe("When I manipulate the form to change the name", () => {
    test('Then the name is changed in the current Grooming Session', () => {
      expect(groomingSessionForm.state.currentGroomingSession.name).toEqual("");
      const nameTextField = wrapper.find(TextField).at(textFieldPosition.name);
      const name = 'Test';
      nameTextField.props().onChange({ target: { value: name } });
      expect(groomingSessionForm.state.currentGroomingSession.name).toEqual(name);
    });
  });

  describe("When I manipulate the form to change the date", () => {
    const expectedDateFormat = 'YYYY-MM-DD';

    test('Then the date is changed in the current Grooming Session', () => {
      const now = moment();
      const currentGroomingSessionFormattedDate = moment(groomingSessionForm.state.currentGroomingSession.date).format(expectedDateFormat);
      expect(currentGroomingSessionFormattedDate).toEqual(now.format(expectedDateFormat));

      const date = moment('23-04-2018', expectedDateFormat);
      const dateTextField = wrapper.find(TextField).at(textFieldPosition.date);
      dateTextField.props().onChange({ target: { value: date.format(expectedDateFormat) } });
      const newGroomingSessionFormattedDate = moment(groomingSessionForm.state.currentGroomingSession.date).format(expectedDateFormat);
      expect(newGroomingSessionFormattedDate).toEqual(date.format(expectedDateFormat));
    });
  });

  describe("When I click the button to submit the form", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = { id: '123', name: 'Posted Grooming Session', date: `${new Date()}` };
      mock.onPost('/groomingSessions').reply(201, data);
    });

    test("Then the form is well fulfilled", () => {
      const addButton = wrapper.find(Button).at(buttonPosition.add);
      addButton.props().onClick();
      return groomingSessionForm.addSubmitPromise.then(() => {
        wrapper.update();
        expect(wrapper.find(Typography).at(typoPositionAfterAddSubmit.newAddedSession).text()).toEqual("Your new Session: Posted Grooming Session is saved");
      });
    });
  });
});
