import React from 'react';
import { mount } from 'enzyme';
import Enzyme from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import { MemoryRouter } from 'react-router-dom';
import ReactRouter from '../components/ReactRouter';
import { Route } from 'react-router-dom';
import MainPage from "../components/MainPage";
import FlorianRandomSentence from '../components/FlorianRandomSentence';
import FlorianSentenceForm from '../components/FlorianSentenceForm';
import FlorianSentencesList from '../components/FlorianSentencesList';
import FlorianSentenceEdit from '../components/FlorianSentenceEdit';
import GroomingSessionForm from '../components/GroomingSessionForm';
import GroomingSessionDetail from '../components/GroomingSessionDetail';

describe("When I'm connected to Steam Scrum app", () => {
  Enzyme.configure({ adapter: new Adapter() });
  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <ReactRouter />
      </MemoryRouter>
    );
  });

  afterEach(() => {
    wrapper.unmount();
  });

  test("Then application router startup", () => {
    const pathMap = wrapper.find(Route).reduce((pathMap, route) => {
      const routeProps = route.props();
      pathMap[routeProps.path] = routeProps.component;
      return pathMap;
    }, {});

    expect(pathMap["/"]).toBe(MainPage);
    expect(pathMap["/florian"]).toBe(FlorianRandomSentence);
    expect(pathMap["/florianSentenceForm"]).toBe(FlorianSentenceForm);
    expect(pathMap["/florianSentencesList"]).toBe(FlorianSentencesList);
    expect(pathMap["/florianSentenceEdit"]).toBe(FlorianSentenceEdit);
    expect(pathMap["/groomingSessionForm"]).toBe(GroomingSessionForm);
    expect(pathMap["/groomingSessionDetail"]).toBe(GroomingSessionDetail);
  });
});
