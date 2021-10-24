import HTMLKit

struct UserStoryVoteData {
    let userStory: UserStory
    let participant: String
}

struct UserStoryVoteTemplate: HTMLTemplate {
    @TemplateValue(UserStoryVoteData.self) var context

    var body: HTMLContent {
        Document(type: .html5) {
            Head {
                MetaTitle { context.userStory.name }
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
                Script().source("/Scripts/UserStoryVote.js").type("module")
            }
            Body {
                Div {
                    H3 { "Refinement Session: " + context.userStory.refinementSession.name }.singleColumn
                    Div {
                        Div {
                            H2 { context.participant + " for: " + context.userStory.name }.singleColumn
                            form.singleColumn
                        }.class("column")
                        Div {
                            H2 { "Vote results" }.singleColumn
                            Div {
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
                            }.singleColumn
                        }.class("column")
                    }.class("row")
                }.class("container")
            }
        }
    }

    private var form: Form {
        Form {
            ForEach(in: fibonacciSequence, content: line)
        }
    }

    private func line(pointsForLine: TemplateValue<[Int]>) -> HTMLContent {
        Div {
            ForEach(in: pointsForLine, content: button)
        }
        .style(css: "display: flex; flex-flow: row wrap; align-items: center; justify-content: center;")
    }

    private func button(points: TemplateValue<Int>) -> HTMLContent {
        Button { points }
            .type(.button)
            .class("button button-outline vote-button")
            .name("points-button")
            .data("points", value: points)
            .style(css: "width: 80px; height: 80px; margin: 8px;")
    }

    private var fibonacciSequence: [[Int]] = [[1, 2, 3], [5, 8, 13], [21, 34, 55]]
}
