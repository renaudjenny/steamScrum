import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {

    let florianSentencesController = FlorianSentencesController()
    router.get("florianSentences", use: florianSentencesController.index)
    router.post("florianSentences", use: florianSentencesController.create)
    router.patch("florianSentences", FlorianSentence.parameter, use: florianSentencesController.patch)
    router.delete("florianSentences", FlorianSentence.parameter, use: florianSentencesController.delete)
    
    router.get("randomFlorianSentence", use: florianSentencesController.randomFlorianSentence)
    router.get("florianSentencesContext", use: florianSentencesController.context)

    let groomingSessionController = GroomingSessionController()
    router.get("groomingSessions", use: groomingSessionController.index)
    router.post("groomingSessions", use: groomingSessionController.create)
}
