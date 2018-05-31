import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("") { (req: Request) throws -> Future<Response> in
        let indexPath = try req.sharedContainer.make(DirectoryConfig.self).workDir + "Public/index.html"
        return try req.streamFile(at: indexPath)
    }

    router.get("florian") { (req: Request) throws -> Future<Response> in
        let indexPath = try req.sharedContainer.make(DirectoryConfig.self).workDir + "Public/index.html"
        return try req.streamFile(at: indexPath)
    }

    router.get("florianSentenceForm") { (req: Request) throws -> Future<Response> in
        let indexPath = try req.sharedContainer.make(DirectoryConfig.self).workDir + "Public/index.html"
        return try req.streamFile(at: indexPath)
    }

    let florianSentencesController = FlorianSentencesController()
    router.get("florianSentences", use: florianSentencesController.index)
    router.post("florianSentences", use: florianSentencesController.create)
    router.get("randomFlorianSentence", use: florianSentencesController.randomFlorianSentence)
    router.get("florianSentencesContext", use: florianSentencesController.context)
    // TODO: don't provide delete route for now
    //router.delete("florianSentences", FlorianSentence.parameter, use: florianSentencesController.delete)

    let groomingSessionController = GroomingSessionController()
    router.get("groomingSessions", use: groomingSessionController.index)
    router.post("groomingSessions", use: groomingSessionController.create)
}
