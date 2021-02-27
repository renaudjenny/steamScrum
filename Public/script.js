// TODO: Extract this part into its own file (See https://github.com/renaudjenny/steamScrum/issues/26)

const setVote = (participant, points) => {
    if (!isWebSocketReady) {
        console.error("Cannot vote, WebSocket isn't ready")
        return
    }

    const vote = { vote: { participant, points }}
    webSocket.send(JSON.stringify(vote))
}
