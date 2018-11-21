import React from "react";
import { mount } from "enzyme";
import Enzyme from "enzyme";
import Adapter from "enzyme-adapter-react-16";
import { MemoryRouter } from "react-router-dom";
import axios from "axios";
import MockAdapter from "axios-mock-adapter";
import FlorianSentencesList from "../components/FlorianSentencesList";
import FlorianSentence from "../components/FlorianSentence";
import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';

describe("Given I'm on the list of Florian Sentences", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let florianSentencesList;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianSentencesList />
      </MemoryRouter>
    );
    florianSentencesList = wrapper.find(FlorianSentencesList).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  const typoPosition = {
    title: 0,
    context: 1,
  };

  describe("When the page is loaded", () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios);

      const sentences = [
        { id: 1, sentence: "First test sentence" },
        { id: 2, sentence: "Second test sentence" },
        { id: 3, sentence: "Third test sentence" },
      ];
      mock.onGet("/florianSentences").reply(200, sentences);

      const context = { sentencesCount: 3, maximumSentencesCount: 250 };
      mock.onGet("/florianSentencesContext").reply(200, context);
    });

    test("Then I can see the Florian sentences context", () => {
      expect.assertions(1);
      return florianSentencesList.mountPromise.then(() => {
        const context = wrapper.find(Typography).at(typoPosition.context);
        expect(context.text()).toBe("Already saved sentences: 3/250");
      });
    });

    test("Then I see 3 Florian sentences", () => {
      expect.assertions(1);
      return florianSentencesList.mountPromise.then(() => {
        wrapper.update();
        const florianSentences = wrapper.find(FlorianSentence);
        expect(florianSentences).toHaveLength(3);
      });
    });

    test("Then I click on a Florian sentence and I'm redirected to the edit form", () => {
      expect.assertions(4);
      return florianSentencesList.mountPromise.then(() => {
        wrapper.update();
        const florianSentences = wrapper.find(FlorianSentence.WrappedComponent);
        const florianSentence = florianSentences.first();
        const history = florianSentence.props().history;
        expect(history).toHaveLength(1);
        florianSentence.find(ListItem).props().onClick();
        expect(history).toHaveLength(2);
        expect(history.action).toBe('PUSH');
        expect(history.location.pathname).toBe('/florianSentenceEdit');
      })
    });
  });
});
