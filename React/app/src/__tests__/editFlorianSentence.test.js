import React from "react";
import { mount } from "enzyme";
import Enzyme from "enzyme";
import Adapter from "enzyme-adapter-react-16";
import { MemoryRouter } from "react-router-dom";
import axios from "axios";
import MockAdapter from "axios-mock-adapter";
import FlorianSentenceEdit from "../components/FlorianSentenceEdit";
import Input from '@material-ui/core/Input';
import Button from '@material-ui/core/Button';

describe("Given I'm on the page to edit a Florian Sentence", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let florianSentenceEdit;

  beforeEach(() => {
    const fakeLocation = {
      state: {
        florianSentence: { 
          id: 123,
          sentence: "A test sentence to edit",
        }
      }
    };

    wrapper = mount(
      <MemoryRouter>
        <FlorianSentenceEdit location={fakeLocation} />
      </MemoryRouter>
    );
    florianSentenceEdit = wrapper.find(FlorianSentenceEdit).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  describe("When the page is shown", () => {
    test("Then I can see the sentence in an editable field", () => {
      const input = wrapper.find(Input);
      expect(input.props().value).toBe("A test sentence to edit");
    });
  });

  describe("When I change the sentence", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);
      mock.onPatch("florianSentences/123").reply(200);
    });

    test("Then I can save it", () => {
      const newSentence = "Sentence is now changed";

      const input = wrapper.find(Input);
      input.props().onChange({ target: { value: newSentence } });

      const axiosPatch = jest.spyOn(axios, "patch");
      const button = wrapper.find(Button);
      button.props().onClick();
      expect(axiosPatch).toHaveBeenCalledWith("florianSentences/123", { sentence: newSentence });
    });
  });
});
