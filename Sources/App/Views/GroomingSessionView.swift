struct GroomingSessionView {
    let groomingSession: GroomingSession

    var render: HTML { HTML(value: """
        <html>
        <head>
        <meta charset="utf-8">
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
        <form>
        <div>
        <label for="name">User Story name: </label>
        <input type="text" name="name" id="name" required>
        </div>
        <div>
        <button type="button" onclick="createUserStory()">
        Submit
        </button>
        </div>
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
