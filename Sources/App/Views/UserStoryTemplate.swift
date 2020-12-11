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
            }
            Body {
                Div {
                    H2 { "Grooming Session: " + context.userStory.groomingSession.name }.singleColumn
                    H1 { context.userStory.name }.singleColumn
                }.class("container")
            }
        }
    }
}
