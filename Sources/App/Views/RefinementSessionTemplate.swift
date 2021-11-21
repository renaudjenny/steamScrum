import HTMLKit

struct RefinementSessionData {
    let refinementSession: RefinementSession
    let maximumAllowed = UserStory.maximumAllowed
}

struct RefinementSessionTemplate: HTMLTemplate {
    @TemplateValue(RefinementSessionData.self) var context

    var body: HTMLContent {
        Html {
            Head {
                MetaTitle { context.refinementSession.name }
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
                Script().source("/Scripts/RefinementSession.js").type("module")
            }
            Body {
                Div {
                    H1 { "Refinement Session: " + context.refinementSession.name }.singleColumn
                    H2 { "Add a User Story" }.singleColumn
                    P { Bold { context.refinementSession.userStories.count + "/" + context.maximumAllowed } }.singleColumn
                    form
                    H2 { "User Stories" }.singleColumn
                    ForEach(in: context.refinementSession.userStories) { userStory in
                        Div {
                            Div {
                                H3 {
                                    Anchor { userStory.name }
                                        .reference(context.refinementSession.id + "/user_stories/" + userStory.id)
                                }
                            }.class("column")
                            Div {
                                Button {
                                    "❌"
                                }
                                .type("button")
                                .class("remove-user-story-button")
                                .data(for: "id", value: userStory.id)
                            }.class("column")
                        }.class("row")
                    }
                }.class("container")
            }
        }
    }

    private var form: Form {
        Form {
            Label { "User Story name" }.for("name")
            Input().type("text").id("name").add(.init(attribute: "name", value: "name")).required()
            Button { "Submit" }.type("submit")
        }.id("add-user-story-form")
    }
}
