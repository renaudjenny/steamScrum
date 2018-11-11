import React from "react";
import { mount } from "enzyme";
import Enzyme from "enzyme";
import Adapter from "enzyme-adapter-react-16";
import { MemoryRouter } from "react-router-dom";
import axios from "axios";
import MockAdapter from "axios-mock-adapter";
import FlorianSentenceForm from "../components/FlorianSentenceForm";
import LinearProgress from '@material-ui/core/LinearProgress';
import Typography from '@material-ui/core/Typography';

describe("Given I'm on the page to add a new Florian Sentence", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let florianSentenceForm;

  const typoPosition = {
    title: 0,
    context: 1,
  };

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianSentenceForm />
      </MemoryRouter>
    );
    florianSentenceForm = wrapper.find(FlorianSentenceForm).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  describe("When data is loading", () => {
    test("Then I see a progress bar pending for data to be loaded", () => {
      const progressBar = wrapper.find(LinearProgress);
      expect(progressBar).toHaveLength(1);
    });
  });

  describe("When data is loaded", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = {
        sentencesCount: 2,
        maximumSentencesCount: 250
      };
      mock.onGet("/florianSentencesContext").reply(200, data);
    });

    test("Then the progress bar disappear", () => {
      expect.assertions(1);
      return florianSentenceForm.mountPromise.then(() => {
        wrapper.update();
        const progressBar = wrapper.find(LinearProgress);
        expect(progressBar).toHaveLength(0);
      });
    });

    test("Then I see the already saved sentences count and how maximum they can be", () => {
      expect.assertions(1);
      return florianSentenceForm.mountPromise.then(() => {
        wrapper.update();
        const context = wrapper.find(Typography).at(typoPosition.context);
        expect(context.text()).toBe("Already saved sentences: 2/250");
      });
    });
  });
});
