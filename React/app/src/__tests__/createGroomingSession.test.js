import React from 'react';
import Enzyme from "enzyme";
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionForm from "../components/GroomingSessionForm";
import Typography from '@material-ui/core/Typography';

describe("Given I'm on the form to create a new Grooming Session", () => {
  Enzyme.configure({ adapter: new Adapter() });
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

  describe("When I'm on the form without doing anything yet", () => {
    test("Then I see the title Add a Grooming Session", () => {
      const title = "Add a Grooming Session";
      const titleTypography = wrapper.find(Typography).filterWhere((typo) => typo.text() === title);
      expect(titleTypography).toHaveLength(1);
    });
  });
});
