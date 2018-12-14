import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { MemoryRouter } from 'react-router-dom'
import axios from 'axios'
import MockAdapter from 'axios-mock-adapter'
import FlorianSentencesList from '../components/FlorianSentencesList'
import FlorianSentence from '../components/FlorianSentence'
import Typography from '@material-ui/core/Typography'
import ListItem from '@material-ui/core/ListItem'
import Modal from '@material-ui/core/Modal'
import DeleteIcon from '@material-ui/icons/Delete'
import Button from '@material-ui/core/Button'
import ListItemText from '@material-ui/core/ListItemText'

describe("Given I'm on the list of Florian Sentences", () => {
  Enzyme.configure({ adapter: new Adapter() })
  let wrapper
  let florianSentencesList

  beforeEach(() => {
    wrapper = mount(
      <MemoryRouter>
        <FlorianSentencesList />
      </MemoryRouter>
    )
    florianSentencesList = wrapper.find(FlorianSentencesList).instance()
  })

  afterEach(() => {
    wrapper.unmount()
  })

  const typoPosition = {
    title: 0,
    context: 1
  }

  const confirmDeleteSentenceModalButtonPosition = {
    confirm: 0,
    cancel: 1
  }

  describe('When the page is loaded', () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios)

      const sentences = [
        { id: 1, sentence: 'First test sentence' },
        { id: 2, sentence: 'Second test sentence' },
        { id: 3, sentence: 'Third test sentence' }
      ]
      mock.onGet('/florianSentences').reply(200, sentences)

      const context = { sentencesCount: 3, maximumSentencesCount: 250 }
      mock.onGet('/florianSentencesContext').reply(200, context)
    })

    test('Then I can see the Florian sentences context', () => {
      expect.assertions(1)
      return florianSentencesList.mountPromise.then(() => {
        const context = wrapper.find(Typography).at(typoPosition.context)
        expect(context.text()).toBe('Already saved sentences: 3/250')
      })
    })

    test('Then I see 3 Florian sentences', () => {
      expect.assertions(1)
      return florianSentencesList.mountPromise.then(() => {
        wrapper.update()
        const florianSentences = wrapper.find(FlorianSentence)
        expect(florianSentences).toHaveLength(3)
      })
    })

    test("Then I click on a Florian sentence and I'm redirected to the edit form", () => {
      expect.assertions(4)
      return florianSentencesList.mountPromise.then(() => {
        wrapper.update()
        const florianSentences = wrapper.find(FlorianSentence.WrappedComponent)
        const florianSentence = florianSentences.first()
        const history = florianSentence.props().history
        expect(history).toHaveLength(1)
        florianSentence.find(ListItem).props().onClick()
        expect(history).toHaveLength(2)
        expect(history.action).toBe('PUSH')
        expect(history.location.pathname).toBe('/florianSentenceEdit')
      })
    })
  })

  describe('When I want to delete a sentence', () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios)

      const sentences = [
        { id: 1, sentence: 'First test sentence to delete' },
        { id: 2, sentence: 'Second test sentence' }
      ]
      mock.onGet('/florianSentences').reply(200, sentences)

      const context = { sentencesCount: 2, maximumSentencesCount: 250 }
      mock.onGet('/florianSentencesContext').reply(200, context)
      mock.onDelete('/florianSentences/1').reply(200)
    })

    test("Then I'm asked to confirm the deletion", () => {
      expect.assertions(2)
      return florianSentencesList.mountPromise.then(() => {
        wrapper.update()
        const firstSentence = wrapper.find(FlorianSentence).at(0)

        const findModalOpenState = () => wrapper.find(Modal).props().open

        expect(findModalOpenState()).toBe(false)

        const deleteButton = firstSentence.find(DeleteIcon)

        deleteButton.props().onClick()
        wrapper.update()
        expect(findModalOpenState()).toBe(true)
      })
    })

    test('Then I confirm the deletion and sentence is removed', () => {
      const findFlorianSentences = () => wrapper.find(FlorianSentence.WrappedComponent)

      expect.assertions(3)
      return florianSentencesList.mountPromise
        .then(() => {
          wrapper.update()
          expect(findFlorianSentences()).toHaveLength(2)

          const firstSentence = findFlorianSentences().at(0)
          const deleteButton = firstSentence.find(DeleteIcon)

          deleteButton.props().onClick()
          wrapper.update()

          const modal = wrapper.find(Modal)
          const confirmButton = modal.find(Button).at(confirmDeleteSentenceModalButtonPosition.confirm)
          confirmButton.props().onClick()
          return florianSentencesList.deletePromise
        })
        .then(() => {
          wrapper.update()
          expect(findFlorianSentences()).toHaveLength(1)
          const florianSentence = findFlorianSentences().at(0)
          const itemText = florianSentence.find(ListItemText)
          expect(itemText.props().primary).toBe('Second test sentence')
        })
    })

    test('Then I cancel the deletion and sentence is removed', () => {
      const findFlorianSentences = () => wrapper.find(FlorianSentence.WrappedComponent)

      expect.assertions(2)
      return florianSentencesList.mountPromise
        .then(() => {
          wrapper.update()
          expect(findFlorianSentences()).toHaveLength(2)

          const firstSentence = findFlorianSentences().at(0)
          const deleteButton = firstSentence.find(DeleteIcon)

          deleteButton.props().onClick()
          wrapper.update()

          const modal = wrapper.find(Modal)
          const confirmButton = modal.find(Button).at(confirmDeleteSentenceModalButtonPosition.cancel)
          confirmButton.props().onClick()
          return florianSentencesList.deletePromise
        })
        .then(() => {
          wrapper.update()
          expect(findFlorianSentences()).toHaveLength(2)
        })
    })
  })

  describe('When a network error occured when the page is loading', () => {
    beforeAll(() => {
      const mock = new MockAdapter(axios)
      mock.onGet('/florianSentences').networkError()
      mock.onGet('/florianSentencesContext').networkError()
    })

    test('Then the page show an empty list', () => {
      expect(wrapper.find(FlorianSentencesList)).toHaveLength(1)
      expect(wrapper.find(FlorianSentence)).toHaveLength(0)
    })
  })
})
