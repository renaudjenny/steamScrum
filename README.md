# Steam Scrum

![CI](https://github.com/renaudjenny/steamScrum/workflows/Swift/badge.svg)

**Steam Scrum** is a project to provide a simple interface to do Scrum Refinements.

The API is written in `Swift` 5.9 thanks to [Vapor](https://vapor.codes).

The final goal of the Scrum part is to list User Stories and compute amount of Story points an US reach.

1. You can create a Refinement Session
2. Inside a Refinement Session, you can create one or more User Story, and add vote participants.
3. Inside an User Story you can select a participant and vote.
4. All participants will have their own interface to vote, and they can see in **real time** who has already voted (thanks to WebSocket).
  * Usually, you will use a video projector to display the User Story, and every voters can scan the QR Code available on the top right to connect to this User Story quickly with their phone or tablet.
5. When all participants have voted, the average score is revealed
6. You can save the vote (actually, you can save several votes if needed, with the average of voted points, so you can easily compare each voting sessions)

All Refinement Sessions and User Stories are saved on the database, including a persistent history of votes for each User Stories if you decide to.

## Website

The interface is pure HTML and a minimum of script (so using VanillaJS), with a minimalistic style (using Milligram to not reinventing the wheel).

It looks very raw, especially in the code for now, but soon or later, I will use [Tokamak](https://github.com/swiftwasm/Tokamak) which allow you to use a subset of SwiftUI to simplify HTML and CSS interaction, and it relies on SwiftWasm for that, which is very promising.

~~You can test this right now here: https://steam-scrum.herokuapp.com~~ Unfortunately, this URL isn't available anymore as Heroku was free for a long while and very convenient for a demo purpose. Until I'm getting my own server, no demo websites are available. Please see below on how to install your own instance, even locally with ease.

### A little bit of history

Previously this was done with Vapor 3 (Swift 4), and I used a simple React app, with the strict minimum of libraries and so. Even that, I was quickly overwhelmed with issues on dependencies (warnings about potential security issues). I didn't want to spend a lot of time upgrading and maintaining this. So it's better to stick with normalized JavaScript, that's why the frontend is so raw now 😆.

## Icons and illustrations

The favicon has been made by [Mathilde Seyller](https://instagram.com/myobriel). Go follow her on Instagram!

## Local development

The easiest way to develop locally Steam Scrum is to use a postgres Docker image.

### Install Docker

Install the last version of Docker, and execute the script named `local-postgres.sh` of this repository. This will install a fresh image of Postgres with name configured and ports so it will be usable with local development version you can run with Swift/Xcode.

### Execute once this command to setup the Database

```bash
swift run Run migrate
```

### If you need to connect to the database at some point to edit things manually

```bash
docker exec -it local-postgres bash
```

```bash
psql -U vapor_database -u vapor_username
\l
```

### Maintenance routine

It's good to maintain package to the last version (and fix the deprecated stuff if some appears in build warnings)

```bash
./maintenance_routine.sh
```

After the packages are update, please run `swift run` and start and exploration test to check everything's working as expected.
