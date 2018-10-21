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
    test("Then I see the title Add a Grooming Session", () => {
      const title = "Add a Grooming Session";
      const titleTypography = wrapper.find(Typography).at(typoPosition.title);
      expect(titleTypography.text()).toBe(title);
    });

    test("Then I see 0 Already saved Grooming Session count, with a maximum of 250 available", () => {
      const mock = new MockAdapter(axios);
      const data = {groomingSessionsCount: 0, maximumGroomingSessionCount: 250};
      mock.onGet('/groomingSessionsContext').reply(200, data);

      expect.assertions(1);
      return groomingSessionForm.mountPromise.then(() => {
        wrapper.update();
        const textTypography = wrapper.find(Typography).at(typoPosition.context)
        expect(textTypography.text()).toBe("Already saved Grooming Sessions: 0/0");
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
});
