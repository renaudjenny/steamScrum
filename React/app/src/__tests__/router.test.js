import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { MemoryRouter, Route } from 'react-router-dom'
import ReactRouter from '../components/ReactRouter'
import MainPage from '../components/MainPage'
import FlorianRandomSentence from '../components/FlorianRandomSentence'
import FlorianSentenceForm from '../components/FlorianSentenceForm'
import FlorianSentencesList from '../components/FlorianSentencesList'
import FlorianSentenceEdit from '../components/FlorianSentenceEdit'
import GroomingSessionForm from '../components/GroomingSessionForm'
import GroomingSessionDetail from '../components/GroomingSessionDetail'
import StoryForm from '../components/StoryForm'

describe("When I'm connected to Steam Scrum app", () => {
  Enzyme.configure({ adapter: new Adapter() })
  let wrapper

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <ReactRouter />
      </MemoryRouter>
    )
  })

  afterEach(() => {
    wrapper.unmount()
  })

  test('Then application router startup', () => {
    const pathMap = wrapper.find(Route).reduce((pathMap, route) => {
      const routeProps = route.props()
      pathMap[routeProps.path] = routeProps.component
      return pathMap
    }, {})

    expect(pathMap['/']).toBe(MainPage)
    expect(pathMap['/florian']).toBe(FlorianRandomSentence)
    expect(pathMap['/florianSentenceForm']).toBe(FlorianSentenceForm)
    expect(pathMap['/florianSentencesList']).toBe(FlorianSentencesList)
    expect(pathMap['/florianSentenceEdit']).toBe(FlorianSentenceEdit)
    expect(pathMap['/groomingSessionForm']).toBe(GroomingSessionForm)
    expect(pathMap['/groomingSessionDetail']).toBe(GroomingSessionDetail)
    expect(pathMap['/createNewStory']).toBe(StoryForm)
  })
})
