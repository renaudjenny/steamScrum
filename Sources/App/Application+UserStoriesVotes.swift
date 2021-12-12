import Vapor

extension Application {
    var refinementSessionParticipants: [RefinementSession.IDValue: [String]] {
        get { storage.get(RefinementSessionStorageKey.self) ?? [:] }
        set {
            storage.set(RefinementSessionStorageKey.self, to: newValue)
            updateWebSockets()
        }
    }

    var userStoriesVotes: [UserStory.IDValue: UserStoryVote] {
        get { storage.get(UserStoryStorageKey.self) ?? [:] }
        set {
            storage.set(UserStoryStorageKey.self, to: newValue)
            updateWebSockets()
        }
    }

    var updateCallbacks: [UUID: () -> Void] {
        get { storage.get(UpdateCallbacksStorageKey.self) ?? [:] }
        set {
            storage.set(UpdateCallbacksStorageKey.self, to: newValue)
        }
    }

    func updateWebSockets() {
        updateCallbacks.values.forEach { $0() }
    }
}

struct RefinementSessionStorageKey: StorageKey {
    typealias Value = [RefinementSession.IDValue: [String]]
}

struct UserStoryStorageKey: StorageKey {
    typealias Value = [UserStory.IDValue: UserStoryVote]
}

struct UpdateCallbacksStorageKey: StorageKey {
    typealias Value = [UUID: () -> Void]
}
