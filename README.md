# Steam Scrum

**Steam Scrum** is a project to provide a simple interface to do Scrum Groomings.

The final goal of the Scrum part is to list User Stories and compute amount of Story points an US reach.

There is two interfaces
  * One for each developers to select his amount of story point for an User Story
  * The other one in the middle of the meeting table who indicates which developer still voting and at the end of the vote show the average.

For now, there is just simple API to manage Grooming Sessions and User Stories.

The interface is pure HTML without any style (CSS). It looks very raw, but soon or later, I will use [Tokamak](https://github.com/swiftwasm/Tokamak) which allow you to use a subset of SwiftUI to simplify HTML and CSS interaction, and it relies on SwiftWasm for that, which is very promising.

## Legacy version

The old and legacy version used Vapor 3 (Swift 4) and React for the rendered part. It's not maintained anymore, but still works.
You can test right now here: https://steam-scrum.herokuapp.com
