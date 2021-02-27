import TokamakDOM

struct TokamakApp: App {
    var body: some Scene {
        WindowGroup("Tokamak App") {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Steam Scrum")
                .font(.title)
                .padding()
            intro.padding()
            Text("Add a Grooming Session")
                .font(.title)
                .padding()
        }
    }

    private var intro: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("This project changed a lot. It has been migrated to the last version of Vapor and is fully rendered in Swift!")
                HTML("a", ["href": "https://github.com/swiftwasm/Tokamak"]) { Text(" See: Tokamak project") }
            }
            HStack {
                Text("The code is available here: ")
                HTML("a", ["href": "https://github.com/renaudjenny/steamScrum"]) { Text("SteamScrum on GitHub") }
            }
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
TokamakApp.main()
