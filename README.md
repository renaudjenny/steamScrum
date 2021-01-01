# Steam Scrum

![CI](https://github.com/renaudjenny/steamScrum/workflows/Swift/badge.svg)

**Steam Scrum** is a project to provide a simple interface to do Scrum Groomings.

The API is written in `Swift` 5.3 thanks to [Vapor](https://vapor.codes).

The final goal of the Scrum part is to list User Stories and compute amount of Story points an US reach.

1. You can create a Grooming Session
2. Inside a Grooming Session, you can create one or more User Story
3. Inside an User Story, you can vote by adding Participants
4. All participants will have their own interface to vote, and they can see in **real time** who has already voted (thanks to WebSocket).
  * Usually, you will use a video projector to display the User Story, and every voters can scan the QR Code available on the top right to connect to this User Story quickly with their phone or tablet.
5. When all participants have voted, the average score is revealed
6. You can save the vote (persisting the vote is *Work in progress*)

All Grooming Sessions and User Stories are saved on the database.

For now, there is just simple API to manage Grooming Sessions and User Stories (without managing story point, it's still WIP).

## Website

The interface is pure HTML and a minimum of script (so using VanillaJS), with a minimalistic style (using Milligram to no reinventing the wheel).

It looks very raw, especially in the code for now, but soon or later, I will use [Tokamak](https://github.com/swiftwasm/Tokamak) which allow you to use a subset of SwiftUI to simplify HTML and CSS interaction, and it relies on SwiftWasm for that, which is very promising.

You can test this right now here: https://steam-scrum.herokuapp.com

### A little bit of history

Previously this was done with Vapor 3 (Swift 4), and I used a simple React app, with the strict minimum of libraries and so. Even that, I was quickly overwhelmed with issues on dependencies (warnings about potential security issues). I didn't want to spend a lot of time upgrading and maintaining this. So it's better to stick with normalized JavaScript, that's why the frontend is so raw now 😆.
