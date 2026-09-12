import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Programmatically build model
        let model = NSManagedObjectModel()

        let todoEntity = NSEntityDescription()
        todoEntity.name = "CDTodo"
        todoEntity.managedObjectClassName = "NSManagedObject"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let titleAttr = NSAttributeDescription()
        titleAttr.name = "title"
        titleAttr.attributeType = .stringAttributeType
        titleAttr.isOptional = false

        let completedAttr = NSAttributeDescription()
        completedAttr.name = "isCompleted"
        completedAttr.attributeType = .booleanAttributeType
        completedAttr.isOptional = false

        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false

        todoEntity.properties = [idAttr, titleAttr, completedAttr, createdAtAttr]
        model.entities = [todoEntity]

        container = NSPersistentContainer(name: "Model", managedObjectModel: model)

        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }

        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Helpers to work with model
    func fetchTodos() throws -> [Todo] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "CDTodo")
        let results = try container.viewContext.fetch(req)
        return results.compactMap { obj in
            guard let id = obj.value(forKey: "id") as? UUID,
                  let title = obj.value(forKey: "title") as? String,
                  let isCompleted = obj.value(forKey: "isCompleted") as? Bool,
                  let createdAt = obj.value(forKey: "createdAt") as? Date
            else { return nil }
            return Todo(id: id, title: title, isCompleted: isCompleted, createdAt: createdAt)
        }
    }

    func save(todo: Todo) throws {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "CDTodo", into: container.viewContext)
        entity.setValue(todo.id, forKey: "id")
        entity.setValue(todo.title, forKey: "title")
        entity.setValue(todo.isCompleted, forKey: "isCompleted")
        entity.setValue(todo.createdAt, forKey: "createdAt")
        try container.viewContext.save()
    }

    func delete(todoID: UUID) throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "CDTodo")
        req.predicate = NSPredicate(format: "id == %@", todoID as CVarArg)
        let results = try container.viewContext.fetch(req)
        for obj in results { container.viewContext.delete(obj) }
        try container.viewContext.save()
    }
}
