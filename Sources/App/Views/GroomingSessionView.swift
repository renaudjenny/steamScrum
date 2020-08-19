struct GroomingSessionView {
    let groomingSession: GroomingSession

    var render: HTML { HTML(value: """
        <html>
        <head>
        <meta charset="utf-8">
        <head>
        <body>
        \(title)
        </body>
        </html>
        """
    )}

    var title: String { """
        <h1>Grooming Session: \(groomingSession.name)</h1>
        """
    }
}
