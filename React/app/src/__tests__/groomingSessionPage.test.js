import React from 'react';
import Enzyme from "enzyme";
import { mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom'
import GroomingSessionDetail from "../components/GroomingSessionDetail";
import Typography from '@material-ui/core/Typography';
import LinearProgress from '@material-ui/core/LinearProgress';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

describe("Given I'm on the Grooming Session Page", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;
  let groomingSessionDetail;

  const typoPosition = {
    title: 0,
    otherSessions: 1
  };

  const typoPositionAfterLoading = {
    title: 0,
    sessionName: 1,
    sessionDate: 2,
    otherSessions: 3
  };

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <GroomingSessionDetail sessionId={123} />
      </MemoryRouter>
    );
    groomingSessionDetail = wrapper.find(GroomingSessionDetail).instance();
  });

  afterEach(() => {
    wrapper.unmount();
  });

  describe("When the page is loading", () => {
    test("Then the title is Grooming Session", () => {
      const typo = wrapper.find(Typography).at(typoPosition.title);
      expect(typo.text()).toBe("Grooming Session");
    });

    test("Then a Progress Bar is shown until the data will be loaded", () => {
      const linearProgress = wrapper.find(LinearProgress);
      expect(linearProgress).toHaveLength(1);
    });

    test("Then a Link to other sessions is available", () => {
      const typo = wrapper.find(Typography).at(typoPosition.otherSessions);
      expect(typo.text()).toBe("Other Sessions");
    });
  });

  describe("When a session is loaded", () => {
    beforeEach(() => {
      const mock = new MockAdapter(axios);
      const data = {
        id: 123,
        name: "Session test 123",
        date: "2018-08-03T05:37:13Z",
        userStories: []
      };
      mock.onGet('/groomingSessions/123').reply(200, data);
    });

    test("Then the Progress Bar disappear", () => {
      expect.assertions(1);
      return groomingSessionDetail.mountPromise.then(() => {
        wrapper.update();
        expect(wrapper.find(LinearProgress)).toHaveLength(0);
      });
    });

    test("Then the name text is the Session name", () => {
      expect.assertions(1);
      return groomingSessionDetail.mountPromise.then(() => {
        wrapper.update();
        const typo = wrapper.find(Typography).at(typoPositionAfterLoading.sessionName);
        expect(typo.text()).toEqual("Session test 123");
      });
    });

    test("Then the date text is the Session date", () => {
      expect.assertions(1);
      return groomingSessionDetail.mountPromise.then(() => {
        wrapper.update();
        const typo = wrapper.find(Typography).at(typoPositionAfterLoading.sessionDate);
        expect(typo.text()).toEqual("August 3, 2018");
      });
    });
  });
});
