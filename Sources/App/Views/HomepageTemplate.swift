import Foundation
import HTMLKit

struct HomepageData {
    let groomingSessions: [GroomingSession]
    let groomingSessionsMaximumAllowed: Int = GroomingSession.maximumAllowed
}

struct HomepageTemplate: HTMLTemplate {
    @TemplateValue(HomepageData.self) var context

    var body: HTML {
        Document(type: .html5) {
            Head {
                Title { "SteamScrum" }
                Author { "Renaud Jenny" }.twitter(handle: "@Renox0")
                Link(attributes: [
                    HTMLAttribute(attribute: "rel", value: "stylesheet"),
                    HTMLAttribute(
                        attribute: "href",
                        value: "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css"
                    ),
                    HTMLAttribute(
                        attribute: "integrity",
                        value: "sha512-xiunq9hpKsIcz42zt0o2vCo34xV0j6Ny8hgEy"
                            + "lN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g=="
                    ),
                    HTMLAttribute(attribute: "crossorigin", value: "anonymous"),
                ])
                script
            }
            Body {
                Div {
                    title
                    groomingForm
                    groomingSessionList
                }.class("container")
            }
        }
    }

    private var title: HTML {
        Div {
            Div {
                Div {
                    H1 { "Steam Scrum" }
                }.class("column")
            }
            .class("row")
            .style(css: "margin-top: 2em")

            Div {
                Div {
                    P {
                        "This project changed a lot. It has been migrated to the last version of Vapor"
                            + " and will sooner be fully rendered in Swift! (See: "
                            + Anchor { "Tokamak project" }.href("https://github.com/swiftwasm/Tokamak")
                            + ")"
                    }
                }.class("column")
            }.class("row")

            Div {
                Div {
                    P {
                        "This is using pure Javascript (without any external libraries), and "
                            + Anchor { "Milligram" }.href("https://milligram.io")
                            + " to give a little bit of style here and there."
                    }
                }.class("column")
            }.class("row")

            Div {
                Div {
                    P {
                        "The code is available here: "
                            + Anchor { "SteamScrum on GitHub" }
                                .href("https://github.com/renaudjenny/steamScrum")
                    }
                }.class("column")
            }.class("row")
        }
    }

    private var script: Script {
        Script {
            """
            const setGroomingSessionDateToNow = () => {
                const formattedDate = new Date().toJSON().slice(0, 10)
                document.getElementById("date").setAttribute("value", formattedDate)
            }

            const removeGroomingSession = (groomingSessionId) =>
                fetch(`grooming_sessions/${groomingSessionId}`, { method: "DELETE" })
                    .then(() => location.reload())

            const createGroomingSession = () => {
                const name = document.getElementById("name").value
                const date = document.getElementById("date").value
                fetch("grooming_sessions", {
                    method: "POST",
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ name, date }),
                })
                .then(() => location.reload())
            }
            """
        }
    }

    private var groomingForm: HTML {
        Div {
            Div {
                Div {
                    H2 { "Add a Grooming Session" }
                }.class("column")
            }.class("row")
            Div {
                Div {
                    Form {
                        Label { "Grooming Session name" }.for("name")
                        Input(type: .text, id: "name").name("name").required()
                        Label { "Date of the session" }.for("date")
                        Div {
                            Div {
                                Input(type: .date, id: "date").name("date").required()
                            }.class("column")
                            Div {
                                Button { "Now" }.type(.button).on(click: "setGroomingSessionDateToNow()")
                            }.class("column")
                        }.class("row")
                        Button { "Submit" }.type(.button).on(click: "createGroomingSession()")
                    }
                }.class("column")
            }.class("row")
        }
    }

    private var groomingSessionList: HTML {
        Div {
            Div {
                Div {
                    H2 { "Grooming Sessions" }
                }.class("column")
            }.class("row")
            Div {
                Div {
                    P { Bold { context.groomingSessions.count + "/" + context.groomingSessionsMaximumAllowed } }
                }.class("column")
            }.class("row")
            ForEach(in: context.groomingSessions) { (groomingSession: TemplateValue<GroomingSession>) in
                Div {
                    Div {
                        H3 { Anchor { groomingSession.name }.href("grooming_sessions/" + groomingSession.id) }
                    }.class("column")
                    Div {
                        Button { "❌" }.type(.button).on(click: "removeGroomingSession(\"" + groomingSession.id + "\")")
                    }.class("column")
                }.class("row")
                Div {
                    Div {
                        H4 { groomingSession.date.style(date: .full, time: .none) }
                    }.class("column")
                }.class("row")
            }
        }
    }
}
