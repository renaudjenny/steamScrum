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
                    HTMLAttribute(attribute: "href", value: "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css"),
                    HTMLAttribute(attribute: "integrity", value: "sha512-xiunq9hpKsIcz42zt0o2vCo34xV0j6Ny8hgEylN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g=="),
                    HTMLAttribute(attribute: "crossorigin", value: "anonymous")
                ])
                script
            }
            Body {
                H1 { "Grooming Session: " + context.groomingSession.name }
                H2 { "Add a User Story" }
                P { Bold { context.groomingSession.userStories.count + "/" + context.maximumAllowed } }
                form
                H2 { "User Stories" }
                ForEach(in: context.groomingSession.userStories) { userStory in
                    H3 { userStory.name }
                }
            }
        }
    }

    private var form: Form {
        Form {
            Label { "User Story name" }.for("name")
            Input(type: .text, id: "name").required()
            Button { "Submit" }.on(click: "createUserStory()")
        }
    }

    private var script: Script {
        Script {
            "const createUserStory = () => {" + "\n"
            "   const name = document.getElementById('name').value" + "\n"
            "   fetch('" + context.groomingSession.id + "/user_stories', {" + "\n"
            "       method: 'POST'," + "\n"
            "       headers: {" + "\n"
            "           'Content-Type': 'application/json'," + "\n"
            "       }," + "\n"
            "       body: JSON.stringify({ name })," + "\n"
            "   })" + "\n"
            "   .then(() => window.location.reload())" + "\n"
            "}"
        }
    }
}
