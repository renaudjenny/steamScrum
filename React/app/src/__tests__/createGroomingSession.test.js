import React from 'react';
import Enzyme from "enzyme";
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionForm from "../components/GroomingSessionForm";
import Typography from '@material-ui/core/Typography';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

describe("Given I'm on the form to create a new Grooming Session", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;

  const typoPosition = {
    title: 0,
    context: 1,
  };

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

      const groomingSessionForm = wrapper.find(GroomingSessionForm).instance();
      expect.assertions(1);
      return groomingSessionForm.mountPromise.then(() => {
        wrapper.update();
        const text = "Already saved Grooming Sessions: 0/0";
        const textTypography = wrapper.find(Typography).at(typoPosition.context)
        expect(textTypography.text()).toBe(text);
      });
    });
  });
});
