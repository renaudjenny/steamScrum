import Routing
import Vapor
import Leaf

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let reactController = ReactController()
    router.get("", use: reactController.index)

    let florianSentencesController = FlorianSentencesController()
    router.get("florianSentences", use: florianSentencesController.index)
    router.post("florianSentences", use: florianSentencesController.create)
    // TODO: don't provide delete route for now
    //router.delete("florianSentences", FlorianSentence.parameter, use: florianSentencesController.delete)
    router.get("florianSentenceForm", use: florianSentencesController.florianSentenceForm)
    router.post("florianSentenceForm", use: florianSentencesController.AddFlorianSentenceFromForm)

    let florianController = FlorianController()
    router.get("florian", use: florianController.whatFlorianSaid)
    router.get("florianNothingToSay", use: florianController.nothingToSay)

    let groomingSessionController = GroomingSessionController()
    router.get("groomingSessions", use: groomingSessionController.index)
    router.post("groomingSessions", use: groomingSessionController.create)
}
