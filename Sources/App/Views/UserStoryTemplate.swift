import HTMLKit

struct UserStoryData {
    let userStory: UserStory
}

struct UserStoryTemplate: HTMLTemplate {
    @TemplateValue(UserStoryData.self) var context

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
                    H1 { context.userStory.name }.singleColumn
                    form
                    Div {
                        H3 { "Vote session" }.singleColumn
                        H4 { "Participants" }.singleColumn
                        Div {
                            P { "Select your name on the list to vote." +
                                "If you're not here yet, use the form above to add you as participant." +
                                "If you just want to be spectator, you can just stay on this page (you don't need to refresh the page to see voting status changing)" }
                            Div { }.id("participants-buttons")
                        }.singleColumn

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

                        Button {
                            "Save this vote"
                        }
                        .add(attributes: [HTMLAttribute(attribute: "disabled", value: "true")])
                        .id("save-button")
                        .on(click: "saveVote()")

                        // TODO: Debug code, remove it ASAP
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
            Label { "Add participant to the vote" }.for("participant")
            Input(type: .text, id: "participant").name("participant").required()
            Button { "Submit" }
                .type(.button)
                .on(click: "addVotingParticipant()")
        }
    }
}
