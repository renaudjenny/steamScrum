import HTMLKit

struct UserStoryData {
    let userStory: UserStory
    let QRCodeSVG: String?
}

struct UserStoryTemplate: HTMLTemplate {
    @TemplateValue(UserStoryData.self) var context

    var body: HTMLContent {
        Html {
            Head {
                MetaTitle { context.userStory.name }
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
                Script().source("/Scripts/UserStory.js").type("module")
            }
            Body {
                Div {
                    Div {
                        H2 { "Refinement Session: " + context.userStory.refinementSession.name }
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
                                    TableHead { "Participant" }
                                    TableHead { "Has voted" }
                                    TableHead { "Points" }
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
                            }.class("column")

                            P {
                                "You'll be able to save the vote when everyone has voted. You also need at least one vote."
                            }
                            .class("column column-80")
                            .id("save-button-help")
                        }.class("row")

                        Div {
                            H2 { "Saved votes" }.singleColumn
                            IF(context.userStory.votes.count <= 0) {
                                P { "No votes have been saved yet." }.singleColumn
                            }
                            ForEach(in: context.userStory.votes) { vote in
                                Div {
                                    H4 { vote.date.style(date: .full, time: .short) }.class("column")
                                    Div {
                                        P { Bold { "Participants" } }
                                        P { vote.participantsListed }
                                    }
                                    .class("column")
                                    P {
                                        Span { "Average: " }
                                        Bold { vote.avgRounded }
                                        Span { " points" }
                                    }
                                    .class("column")
                                    Div {
                                        Button {
                                            "❌"
                                        }
                                        .type("button")
                                        .class("remove-user-story-vote-button")
                                        .data(for: "id", value: vote.id)
                                    }
                                    .class("column")
                                }
                                .class("row")
                            }
                        }
                    }
                    .singleColumn
                }.class("container")
            }
        }
    }

    private var form: Form {
        Form {
            Label { "Add participant to the vote" }.for("participant")
            Input().type("text").id("participant").required()
            Button { "Add" }.type("submit")
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

private extension UserStoryVote {
    var avgRounded: String? {
        guard let avg = avg else { return nil }
        return String(format: "%.2f", avg)
    }

    var participantsListed: String {
        participants.joined(separator: ", ")
    }
}
