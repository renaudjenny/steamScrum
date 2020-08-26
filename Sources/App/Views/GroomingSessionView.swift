struct GroomingSessionView {
    let groomingSession: GroomingSession
    let maximumAllowed = UserStoryContext.maximumAllowed

    var render: HTML { HTML(value: """
        <html>
        <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css" integrity="sha512-xiunq9hpKsIcz42zt0o2vCo34xV0j6Ny8hgEylN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g==" crossorigin="anonymous"
        />
        \(script)
        <head>
        <body>
        \(title)
        \(userStoryForm)
        \(userStories)
        </body>
        </html>
        """
    )}

    private var title: String { "<h1>Grooming Session: \(groomingSession.name)</h1>" }

    private var userStoryForm: String { """
        <h2>Add a User Story</h2>
        <p><strong>\(groomingSession.userStories.count)/\(maximumAllowed)</strong></p>
        <form>
            <fieldset>
                <label for="name">User Story name: </label>
                <input type="text" name="name" id="name" required>
                <button type="button" onclick="createUserStory()">
                    Submit
                </button>
            </fieldset>
        </form>
        """
    }

    private var userStories: String { """
        <h2>User Stories</h2>
        \(groomingSession.userStories.map({ userStory in
        """
        <div>
        <h3>\(userStory.name)</h3>
        </div>
        """
        }).joined(separator: "<br />")
        )
        """
    }

    private var script: String { """
        <script>
        const createUserStory = () => {
            const name = document.getElementById("name").value
            fetch("\(groomingSession.id!)/user_stories", {
                method: "POST",
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ name }),
            })
            .then(() => location.reload())
        }
        </script>
        """
    }
}
