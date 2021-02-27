import { ids } from "./Common.js"

export const UserStoryWebSocket = (onMessageReceived) => {
    const { refinementSessionId, userStoryId } = ids()
    const url = new URL(window.location.href)
    const protocol = url.protocol === 'http:' ? 'ws' : 'wss'
    const webSocketURL = `${protocol}://${url.host}/refinement_sessions/${refinementSessionId}/user_stories/${userStoryId}/vote/connect`

    let webSocket
    window.addEventListener("DOMContentLoaded", () => {
        webSocket = new WebSocket(webSocketURL)

        webSocket.addEventListener("open", (event) => {
            webSocket.send("connection-ready")
        })

        webSocket.addEventListener("message", (event) => {
            if (event.data[0] !== "{") {
                console.error("Error: Cannot parse this message: " + event.data)
                return
            }
            const data = JSON.parse(event.data)
            onMessageReceived(data)
        })
    })

    return {
        isWebSocketReady: () => webSocket?.readyState === WebSocket.OPEN,
        send: (data) => webSocket.send(data),
    }
}
