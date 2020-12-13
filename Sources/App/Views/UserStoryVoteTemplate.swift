import HTMLKit

struct UserStoryVoteData {
    let userStory: UserStory
    let participant: String
}

struct UserStoryVoteTemplate: HTMLTemplate {
    @TemplateValue(UserStoryVoteData.self) var context

    var body: HTML {
        Document(type: .html5) {
            Head {
                Title { context.userStory.name }
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
                            + "lN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g=="),
                    HTMLAttribute(attribute: "crossorigin", value: "anonymous"),
                ])
                Script().source("/script.js")
                Script() { "connectToTheUserStoryVoteWebSocket()" }
            }
            Body {
                Div {
                    H2 { "Grooming Session: " + context.userStory.groomingSession.name }.singleColumn
                    H1 { context.participant }
                    H1 { "Vote for: " + context.userStory.name }.singleColumn
                    form
                    H2 { "Vote results" }
                    Div {
                        Table {
                            TableHead {
                                TableRow {
                                    TableHeader { "Participant" }
                                    TableHeader { "Has voted" }
                                    TableHeader { "Points" }
                                }
                            }
                            TableBody {

                            }.id("participants-table")
                        }.singleColumn
                        H4 { "Data" }.singleColumn
                        P {
                            "Error: No Data received yet from the WebSocket"
                        }
                        .id("vote-session-data")
                        .singleColumn
                    }
                    .singleColumn
                }.class("container")
            }
        }
    }

    private var form: Form {
        Form {
            // TODO: 3x3 Grid instead of all aligned
            ForEach(in: fibonacciSequence) { points in
                Button { points }
                    .type(.button)
                    .class("button button-outline")
                    .on(click: "setVote(\"" + context.participant + "\", " + points + ")")
            }
        }
    }

    private var fibonacciSequence: [Int] = [1, 2, 3, 5, 8, 13, 21, 34, 55]
}
