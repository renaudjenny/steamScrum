import TokamakShim

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
            Text("Steam Scrum").font(.title)
            intro//.multilineTextAlignment(.leading)
            Text("Add a Grooming Session").font(.title)
        }
    }

    private var intro: some View {
        VStack {
            Text("This project changed a lot. It has been migrated to the last version of Vapor and is fully rendered in Swift! ")
                + Text("(See: Tokamak project)")
            Text("This is using pure Javascript (without any external libraries), and ")
                + Text("Milligram")
                + Text(" to give a little bit of style here and there.")
            Text("The code is available here: ") + Text("SteamScrum on GitHub")
        }
    }
}

//_ = document.head.object!.insertAdjacentHTML!("beforeend", #"""
//<link
//  rel="stylesheet"
//  href="https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css"
//  integrity="sha512-xiunq9hpKsIcz42zt0o2vCo34xV0j6Ny8hgEylN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g=="
//  crossorigin="anonymous">
//"""#)

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
TokamakApp.main()
