<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</center>

# Steam Scrum

**Steam Scrum** is a project to provide a simple interface to do Scrum Groomings.

The aim of the Scrum part is to list User Stories and compute amount of Story points an US reach.

There is two interfaces
  * One for each developers to select his amount of story point for an User Story
  * The other one in the middle of the meeting table who indicates which developer still voting and at the end of the vote show the average.

You can test right now here: https://steam-scrum.herokuapp.com

# Install

## macOS

The simple way to use it, is with macOS because Vapor projet (written in Swift) works well with XCode on macOS.

  1. Download the latest version of XCode. Use the App Store do to it.
  2. Install [Homebrew](https://brew.sh).
  3. I suggest you to install Docker for the database. I used this [Postgresql image](https://hub.docker.com/_/postgres/) for development.
  4. Do a `brew install yarn`. An ES6 package manager and more.
  5. Clone the projet. `git clone git@github.com:renaudjenny/steamScrum.git`
  6. In the project folder (`cd steamScrum`). Do `./react-build.sh` to build `.js`, `.css` files and all needs for frontend.
  7. Run your Posgresql database. Default location and port is `localhost:5432`.
    * Don't try to use `Dockerfile` or `docker-compose` now. It's a Work in progress stuff.
  8. Open the project in XCode. Select the scheme `Run` and `My Mac` in devices. Click the Run button.
  9. Default URL for the local website is : `http://localhost:8080`

## Linux

**TODO**
