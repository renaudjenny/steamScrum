import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { MemoryRouter } from 'react-router-dom'
import StoryForm from '../components/StoryForm'
import Typography from '@material-ui/core/Typography'
import TextField from '@material-ui/core/TextField'
import Button from '@material-ui/core/Button'
import Chip from '@material-ui/core/Chip'
import LinearProgress from '@material-ui/core/LinearProgress'
import axios from 'axios'
import MockAdapter from 'axios-mock-adapter'

describe("Given I'm on the form to add a new Story", () => {
  Enzyme.configure({ adapter: new Adapter() })
  let wrapper
  let storyForm

  const typoPositionBeforeLoading = {
    title: 0,
    developersTitle: 1
  }

  const fieldPosition = {
    name: 0,
    developerName: 1
  }

  const buttonPosition = {
    addDeveloper: 0
  }

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <StoryForm sessionId={123} />
      </MemoryRouter>
    )
    storyForm = wrapper.find(StoryForm.WrappedComponent).instance()
  })

  afterEach(() => {
    wrapper.unmount()
  })

  describe('When the page is loading', () => {
    test('Then I see the title Add a new Story', () => {
      const title = wrapper.find(Typography).at(typoPositionBeforeLoading.title)
      expect(title.text()).toBe('Add a new Story')
    })

    test('Then I see a field to set the name of the Story', () => {
      const field = wrapper.find(TextField).at(fieldPosition.name)
      expect(field.text()).toBe('Story name')
    })

    test('Then I see a Progress Bar until the data is loaded', () => {
      const progress = wrapper.find(LinearProgress)
      expect(progress).toHaveLength(1)
    })

    test('Then I see a title to the section to developers', () => {
      const title = wrapper.find(Typography).at(typoPositionBeforeLoading.developersTitle)
      expect(title.text()).toBe('Developers')
    })

    test('Then I see a field to add a new developer', () => {
      const field = wrapper.find(TextField).at(fieldPosition.developerName)
      expect(field.text()).toBe('Developer name')
    })

    test('Then I see a button to add a new developer', () => {
      const button = wrapper.find(Button).at(buttonPosition.addDeveloper)
      expect(button.text()).toBe('Add')
    })
  })

  describe('When I click on the Add a new developper button', () => {
    test('Then the developer name is added to the developers list', () => {
      const findDeveloperChips = () => wrapper.find(Chip)
      expect(findDeveloperChips()).toHaveLength(0)
      const field = wrapper.find(TextField).at(fieldPosition.developerName)
      field.props().onChange({ target: { value: 'Mario' } })
      const button = wrapper.find(Button).at(buttonPosition.addDeveloper)
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(1)
      expect(findDeveloperChips().text()).toBe('Mario')
    })

    test("Then add an empty named developer to the developers list doesn't work", () => {
      const findDeveloperChips = () => wrapper.find(Chip)
      expect(findDeveloperChips()).toHaveLength(0)
      const field = wrapper.find(TextField).at(fieldPosition.developerName)
      field.props().onChange({ target: { value: '' } })
      const button = wrapper.find(Button).at(buttonPosition.addDeveloper)
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(0)
    })

    test("Then add the same developer name twice or more to the developers list doesn't work", () => {
      const findDeveloperChips = () => wrapper.find(Chip)
      expect(findDeveloperChips()).toHaveLength(0)
      const field = wrapper.find(TextField).at(fieldPosition.developerName)
      field.props().onChange({ target: { value: 'Mario' } })
      const button = wrapper.find(Button).at(buttonPosition.addDeveloper)
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(1)

      field.props().onChange({ target: { value: 'Luigi' } })
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(2)

      field.props().onChange({ target: { value: 'Mario' } })
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(2)
    })

    test('Then I delete a developer name form the developers list', () => {
      const findDeveloperChips = () => wrapper.find(Chip)
      expect(findDeveloperChips()).toHaveLength(0)
      const field = wrapper.find(TextField).at(fieldPosition.developerName)
      field.props().onChange({ target: { value: 'Mario' } })
      const button = wrapper.find(Button).at(buttonPosition.addDeveloper)
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(1)

      field.props().onChange({ target: { value: 'Luigi' } })
      button.props().onClick()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(2)

      const firstChip = findDeveloperChips().first()
      firstChip.props().onDelete()
      wrapper.update()
      expect(findDeveloperChips()).toHaveLength(1)
      expect(findDeveloperChips().text()).toBe('Luigi')
    })
  })

  describe('When the page is loaded', () => {
    const typoPositionAfterLoading = {
      title: 0,
      groomingSessionName: 1,
      developersTitle: 2
    }

    beforeAll(() => {
      const mock = new MockAdapter(axios)
      const data = {
        id: 123,
        name: 'Session test 123',
        date: '2018-08-03T05:37:13Z',
        userStories: []
      }
      mock.onGet('/groomingSessions/123').reply(200, data)
    })

    test('Then the Progress Bar is gone', () => {
      expect.assertions(2)

      const findLinearProgress = () => wrapper.find(LinearProgress)
      expect(findLinearProgress()).toHaveLength(1)

      return storyForm.mountPromise.then(() => {
        wrapper.update()
        expect(findLinearProgress()).toHaveLength(0)
      })
    })

    test('Then I see the Grooming Session name with a name on it to go back to the Grooming Session', () => {
      expect.assertions(5)
      return storyForm.mountPromise.then(() => {
        wrapper.update()
        const groomingSessionName = wrapper.find(Typography).at(typoPositionAfterLoading.groomingSessionName)
        expect(groomingSessionName.text()).toBe('Session test 123')

        const history = storyForm.props.history
        expect(history).toHaveLength(1)

        groomingSessionName.props().onClick()
        expect(history).toHaveLength(2)
        expect(history.action).toBe('PUSH')
        expect(history.location.pathname).toBe('/GroomingSessionDetail')
      })
    })
  })
})
