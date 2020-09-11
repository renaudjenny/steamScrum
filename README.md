# Steam Scrum

![CI](https://github.com/renaudjenny/steamScrum/workflows/Swift/badge.svg)

**Steam Scrum** is a project to provide a simple interface to do Scrum Groomings.

The API is written in `Swift` 5.2 thanks to [Vapor](https://vapor.codes).

The final goal of the Scrum part is to list User Stories and compute amount of Story points an US reach.

There is two interfaces
  * One for each developers to select his amount of story point for an User Story
    * Could be done via an application (mobile and/or desktop) or directly on the website?
  * The other one in the middle of the meeting table who indicates which developer still voting and at the end of the vote show the average.
    * Could be done via the website (with WebSocket or polling), or via an application a tablet?

For now, there is just simple API to manage Grooming Sessions and User Stories (without managing story point, it's still WIP).

## Website

The interface is pure HTML and a minimum of script (so using VanillaJS), with a minimalistic style (using Milligram to no reinventing the wheel). 

It looks very raw, especially in the code for now, but soon or later, I will use [Tokamak](https://github.com/swiftwasm/Tokamak) which allow you to use a subset of SwiftUI to simplify HTML and CSS interaction, and it relies on SwiftWasm for that, which is very promising.

You can test this right now here: https://steam-scrum.herokuapp.com

### A little bit of history

Previously this was done with Vapor 3 (Swift 4), and I used a simple React app, with the strict minimum of libraries and so. Even that, I was quickly overwhelmed with issues on dependencies (warnings about potential security issues). I didn't want to spend a lot of time upgrading and maintaining this. So it's better to stick with normalized JavaScript, that's why the frontend is so raw now 😆.
