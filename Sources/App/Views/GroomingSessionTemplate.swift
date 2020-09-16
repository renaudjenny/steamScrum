import HTMLKit

struct GroomingSessionData {
    let groomingSession: GroomingSession
    let maximumAllowed = UserStoryContext.maximumAllowed
}

struct GroomingSessionTemplate: HTMLTemplate {
    @TemplateValue(GroomingSessionData.self) var context

    var body: HTML {
        Document(type: .html5) {
            Head {
                Title { context.groomingSession.name }
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
            }
            Body {
                Div {
                    H1 { "Grooming Session: " + context.groomingSession.name }.singleColumn
                    H2 { "Add a User Story" }.singleColumn
                    P { Bold { context.groomingSession.userStories.count + "/" + context.maximumAllowed } }.singleColumn
                    form
                    H2 { "User Stories" }.singleColumn
                    ForEach(in: context.groomingSession.userStories) { userStory in
                        Div {
                            Div {
                                H3 { userStory.name }
                            }.class("column")
                            Div {
                                Button {
                                    "❌"
                                }
                                .type(.button)
                                .on(click: "removeUserStory(\"" + userStory.id + "\")")
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
            Input(type: .text, id: "name").name("name").required()
            Button { "Submit" }
                .type(.button)
                .on(click: "createUserStory()")
        }
    }
}
