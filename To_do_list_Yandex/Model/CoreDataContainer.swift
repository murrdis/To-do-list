import Foundation
import CoreData

final class CoreDataContainer {
    static let shared = CoreDataContainer()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { description, error in
            if let error {
                print(error.localizedDescription)
            } else {
                print("CoreData file: ", description.url?.absoluteString ?? "")
            }
        }
        return container
    }()
}
