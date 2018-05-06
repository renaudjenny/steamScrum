import Routing
import Vapor
import Leaf

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get { req in
        return "Something will come soon... or later!"
    }

    let florianSentencesController = FlorianSentencesController()
    router.get("florianSentences", use: florianSentencesController.index)
    router.post("florianSentences", use: florianSentencesController.create)
    // TODO: don't provide delete route for now
    //router.delete("florianSentences", FlorianSentence.parameter, use: florianSentencesController.delete)
    router.get("florianSentenceForm", use: florianSentencesController.florianSentenceForm)
    router.post("florianSentenceForm", use: florianSentencesController.AddFlorianSentenceFromForm)

    let florianController = FlorianController()
    router.get("florian", use: florianController.whatFlorianSaid)
}
