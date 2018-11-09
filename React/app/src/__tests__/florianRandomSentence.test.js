import React from "react";
import { mount } from "enzyme";
import Enzyme from "enzyme";
import Adapter from "enzyme-adapter-react-16";
import { MemoryRouter } from "react-router-dom";
import axios from "axios";
import MockAdapter from "axios-mock-adapter";
import FlorianRandomSentence from "../components/FlorianRandomSentence";
import CircularProgress from "@material-ui/core/CircularProgress";
import Typography from "@material-ui/core/Typography";

describe("Given I'm on Florian Random Sentence page", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let florianRandomSentence;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianRandomSentence />
      </MemoryRouter>
    );
    florianRandomSentence = wrapper.find(FlorianRandomSentence).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  describe("When the sentence is loading", () => {
    test("Then I see a bubble with a loading spinner", () => {
      const spinner = wrapper.find(CircularProgress);
      expect(spinner).toHaveLength(1);
    });
  });

  describe("When a sentence is loaded", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      const data = { sentence: "A test sentence from Florian" };
      mock.onGet("/randomFlorianSentence").reply(200, data);
    });

    test("Then I see a sentence in the bubble", () => {
      expect.assertions(1);
      return florianRandomSentence.mountPromise.then(() => {
        wrapper.update();
        const sentence = wrapper.find(Typography);
        expect(sentence.text()).toBe("A test sentence from Florian");
      });
    });
  });
});
