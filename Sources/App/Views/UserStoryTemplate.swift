import HTMLKit

struct UserStoryData {
    let userStory: UserStory
    let QRCodeSVG: String?
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
                Script { "connectToTheUserStoryVoteWebSocket()" }
                Script { "preventFormSubmit('add-participant-form')" }
            }
            Body {
                Div {
                    Div {
                        H2 { "Grooming Session: " + context.userStory.groomingSession.name }
                        H1 { context.userStory.name }
                    }
                    .class("float-left")
                    Div {
                        context.QRCodeSVG.escaping(.unsafeNone)
                    }
                    .class("float-right")

                    Div {
                        H3 { "Vote session" }.singleColumn
                        H4 { "Participants" }.singleColumn
                        Div {
                            Div {
                                participantHelp
                                Div { "" }.id("participants-buttons")
                            }.class("column")
                            form.class("column")
                        }.class("row")

                        Table {
                            TableHead {
                                TableRow {
                                    TableHeader { "Participant" }
                                    TableHeader { "Has voted" }
                                    TableHeader { "Points" }
                                }
                            }
                            TableBody {
                                ""
                            }.id("participants-table")
                        }.singleColumn

                        Div {
                            Div {
                                Button {
                                    "Save this vote"
                                }
                                .add(attributes: [HTMLAttribute(attribute: "disabled", value: "true")])
                                .id("save-button")
                                .on(click: "saveVote()")
                            }.class("column")

                            P {
                                "You'll be able to save the vote when everyone has voted. You also need at least one vote."
                            }
                            .class("column column-80")
                            .id("save-button-help")
                        }.class("row")
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
            Button { "Add" }.type(.submit)
        }.id("add-participant-form")
    }

    private var participantHelp: P {
        P {
            "Select your name on the list to vote. "
                + "If you're name isn't here yet, use the form above to add it. "
                + "If you just want to be spectator, you can just stay on this page "
                + "(you don't need to refresh the page to see voting status changing)"
        }
    }
}
