//
//  CoreDataPlant.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 11/06/24.
//

import Foundation
import CoreData

class CoreDataPlant {
    private let container: NSPersistentContainer!
    init(){
        //container = NSPersistentContainer(name: "GardenGuideCoreData")
        container = NSPersistentContainer(name: "GardenGuideCoreData", managedObjectModel: PersistenceManager.managedObjectModel)
        setUpDataBase()
    }
    
    private func setUpDataBase(){
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR \(description) — \(error)")
                return
            } else {
                print("Plant database ready! ")
            }
        }
    }
    

    
    //MARK: Core Data Saving support
      func save () {
        let context = container.viewContext
        if context.hasChanges {
          do {
              try context.save()
          } catch {
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
        }
      }
    
    
    //MARK: Save new plant
    func savePlant(plant: PlantInformation, watered: IrrigationInformation){
        let idU = UUID() /***Creamos un identificador unico para cada receta*/
        /*para poder interactuar con la base de datos es necesario contar con un NSManagedObjectContext*/
        let context = container.viewContext
          
        /*Creamos un objeto Recipe utilizando como parámetro el contexto anterior. Asociamos sus propiedades con los parámetros recibidos en el método*/
        let Plant = PlantEntity(context: context)
        Plant.name = plant.name
        Plant.id = idU
        Plant.isAdded = plant.isAdded
        
        
        let Watered = WateredEntity(context: context)
        Watered.numberOfDays = watered.numberOfDays
        Watered.waterAmount = watered.waterAmount
        Watered.percentage = watered.percentage
        Watered.wasItWatered = watered.wasItWatered
        Watered.nextIrrigation = watered.nextIrrigation
        Watered.belongsToPlantEntity = Plant
        
        
        if let similarImages = plant.similarImages, similarImages.count >= 1 {
            for index in 0 ..< 2 {
                let SimilarImage = SimilarImagesEntity(context: context)
                SimilarImage.id = similarImages[index].id
                SimilarImage.similarity = similarImages[index].similarity
                SimilarImage.url = similarImages[index].url
                SimilarImage.image = similarImages[index].image
                Plant.addToSimilarImages(SimilarImage)
                SimilarImage.belongsToPlantEntity = Plant
            }
        }
        
        let PlantDetails = PlantDetailsEntity(context: context)
        
        
        if let commonNames = plant.details.commonNames {
            for index in 0 ..< commonNames.count {
                let CommonName = CommonNamesEntity(context: context)
                CommonName.name = commonNames[index]
                PlantDetails.addToCommonNames(CommonName)
                CommonName.belongsToPlantDetailsEntity = PlantDetails
            }
        }
        
        if let synonyms = plant.details.synonyms {
            for index in 0 ..< synonyms.count {
                let Synonyms = SynonymsEntity(context: context)
                Synonyms.synonymous = synonyms[index]
                PlantDetails.addToSynonyms(Synonyms)
                Synonyms.belongsToPlantDetailsEntity = PlantDetails
            }
        }
        
        if let propagationMethods = plant.details.propagationMethods {
            for index in 0 ..< propagationMethods.count {
                let PropagationMethods = PropagationMethodsEntity(context: context)
                PropagationMethods.method = propagationMethods[index]
                PlantDetails.addToPropagationMethods(PropagationMethods)
                PropagationMethods.belongsToPlantDetailsEntity = PlantDetails
            }
        }
        
        if let edibleParts = plant.details.edibleParts {
            for index in 0 ..< edibleParts.count {
                let EdibleParts = EdiblePartsEntity(context: context)
                EdibleParts.part = edibleParts[index]
                PlantDetails.addToEdibleParts(EdibleParts)
                EdibleParts.belogsToPlantDetailsEntity = PlantDetails
            }
        }
        
        
        PlantDetails.wateringMax = Int16(plant.details.watering?.max ?? 0)
        PlantDetails.wateringMin = Int16(plant.details.watering?.min ?? 0)
        PlantDetails.descriptionImageUrl = plant.details.image?.url
        PlantDetails.descriptionUrl = plant.details.description?.url
        PlantDetails.descriptionValue = plant.details.description?.value
        PlantDetails.rank = plant.details.rank
        PlantDetails.url = plant.details.url
        PlantDetails.escriptionImage = plant.details.image?.image
        PlantDetails.belongsToPlantEntity = Plant
        
                
        /*Almacenamos la informacion en la base de datos para ello tenemos que utilizar la función save del NSManagedObjectContext. Esta puede lanzar excepciones por lo que es necesario manejarlo con un try / catch.*/
        do {
            try context.save()
            print("Saved Plant")
        } catch {
             
            print("Error saving plant — \(error)")
        }
    }
    
    //MARK: Search and return all plants
    func fetchPlants() -> [PlantEntity] {
        /*Obtenemos un objeto NSFetchRequest mediante la función de clase fetchRequest indicando mediante <> el tipo de objeto que esperamos recibir*/
        let fetchRequest : NSFetchRequest<PlantEntity> = PlantEntity.fetchRequest()
        
        /*Invocamos el método fetch del viewContext del contenedor para obtener un arreglo de Recipes, este bloque puede arrojar una excepción por lo que se debe contemplar dentro de un bloque try/catch*/
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("The error obtaining plants \(error)")
        }
        
        
        return []
    }
    
    
    //MARK: Search and return last saved Plant
    func returnLastSavedPlant() -> PlantEntity? {
        /*Obtenemos un objeto NSFetchRequest mediante la función de clase fetchRequest indicando mediante <> el tipo de objeto que esperamos recibir*/
        let fetchRequest : NSFetchRequest<PlantEntity> = PlantEntity.fetchRequest()
        
        /*Invocamos el método fetch del viewContext del contenedor para obtener un arreglo de Recipes, este bloque puede arrojar una excepción por lo que se debe contemplar dentro de un bloque try/catch*/
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            return result.last
        } catch {
            print("The error obtaining plants \(error)")
        }
        
        
        return nil
    }
    
    //MARK: search and return plant details
    //Search and return all plant details of the plant
    func fetchPlantDetails(plant: PlantEntity) -> PlantDetailsEntity? {
        //We create and configure the request to make the request for the plant details
        let request: NSFetchRequest<PlantDetailsEntity> = PlantDetailsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantEntity = %@", plant)
        request.sortDescriptors = [NSSortDescriptor(key: "wateringMax", ascending: false)]
        var fetchedPlantDetails: [PlantDetailsEntity] = []
        do {
            fetchedPlantDetails = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching plant details \(error)")
        }
        let plantDetails = fetchedPlantDetails.first
        return plantDetails
    }

    //Search and return all similar names of the plant
    func fetchCommonNames(plantDetails: PlantDetailsEntity) -> [String]? {
        //We create and configure the request to make the request for the common name array
        let request: NSFetchRequest<CommonNamesEntity> = CommonNamesEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantDetailsEntity = %@", plantDetails)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        var fetchedCommonNames: [CommonNamesEntity] = []
        do {
            fetchedCommonNames = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching common names \(error)")
        }
        guard let _ = fetchedCommonNames.first?.name else {
            return nil
        }
        let commonNames = fetchedCommonNames.map { $0.name ?? "" }
        return commonNames
    }
    
    //Search and return all edible parts of the plant
    func fetchEdibleParts(plantDetails: PlantDetailsEntity) -> [String]? {
        //We create and configure the request to make the request for the edible parts array
        let request: NSFetchRequest<EdiblePartsEntity> = EdiblePartsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belogsToPlantDetailsEntity = %@", plantDetails)
        request.sortDescriptors = [NSSortDescriptor(key: "part", ascending: false)]
        var fetchedEdibleParts: [EdiblePartsEntity] = []
        do {
            fetchedEdibleParts = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching edible parts \(error)")
        }
        guard let _ = fetchedEdibleParts.first?.part else {
            return nil
        }
        let edibleParts = fetchedEdibleParts.map { $0.part ?? ""}
        return edibleParts
    }
    
    //Search and return all propagation methods of the plant
    func fetchPropagationMethods(plantDetails: PlantDetailsEntity) -> [String]? {
        //We create and configure the request to make the request for the propagation methods array
        let request: NSFetchRequest<PropagationMethodsEntity> = PropagationMethodsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantDetailsEntity = %@", plantDetails)
        request.sortDescriptors = [NSSortDescriptor(key: "method", ascending: false)]
        var fetchedPropagationMethods: [PropagationMethodsEntity] = []
        do {
            fetchedPropagationMethods = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching propagation methods \(error)")
        }
        guard let _ = fetchedPropagationMethods.first?.method else {
            return nil
        }
        let propagationMethods = fetchedPropagationMethods.map { $0.method ?? ""}
        return propagationMethods
    }
    
    //Search and return all synonyms  of the plant
    func fetchSynonyms(plantDetails: PlantDetailsEntity) -> [String]? {
        //We create and configure the request to make the request for the synonyms array
        let request: NSFetchRequest<SynonymsEntity> = SynonymsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantDetailsEntity = %@", plantDetails)
        request.sortDescriptors = [NSSortDescriptor(key: "synonymous", ascending: false)]
        var fetchedSynonyms: [SynonymsEntity] = []
        do {
            fetchedSynonyms = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching synonyms \(error)")
        }
        guard let _ = fetchedSynonyms.first?.synonymous else {
            return nil
        }
        let synonyms = fetchedSynonyms.map { $0.synonymous ?? ""}
        return synonyms
    }
    
    //MARK: search and return similar images
    //Search and return all similar images of the plant
    func fetchSimilarImages(plant: PlantEntity) -> [SimilarImagesEntity] {
        //We create and configure the request to make the request for the similar images
        let request: NSFetchRequest<SimilarImagesEntity> = SimilarImagesEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantEntity = %@", plant)
        request.sortDescriptors = [NSSortDescriptor(key: "similarity", ascending: false)]
        var fetchedSimilarImages: [SimilarImagesEntity] = []
        do {
            fetchedSimilarImages = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching similar images \(error)")
        }
        //let similarImages = fetchedSimilarImages.first
        return fetchedSimilarImages //similarImages
    }
    
    //MARK: Search and return details of plant watering
    //Search and return details of plant watering
    func fetchWatered(plant: PlantEntity) -> WateredEntity? {
        //We create and configure the request to make the request for the watered
        let request: NSFetchRequest<WateredEntity> = WateredEntity.fetchRequest()
        request.predicate = NSPredicate(format: "belongsToPlantEntity = %@", plant)
        request.sortDescriptors = [NSSortDescriptor(key: "numberOfDays", ascending: false)]
        var fetchedWatered: [WateredEntity] = []
        do {
            fetchedWatered = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching watered \(error)")
        }
        let watered = fetchedWatered.first
        return watered
    }
    
    
    
    //MARK: Modify the the plant
    //Modify the the plant if it is in favorites or not
    func editPlantToFavorites(withUID uID: UUID, addedtofavorites isSeleted: Bool){
        //configure the fetchRequest
        let fetchRequest: NSFetchRequest<PlantEntity>
        fetchRequest = PlantEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", uID as CVarArg )
        fetchRequest.includesPropertyValues = false
        
        let context = container.viewContext
        do {
            //modify the values of the context
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                object.isAdded = isSeleted
            }
            
        } catch {
            print("ERROR: \(error)")
        }
        
        do {
            try context.save()
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    //Modify the new watering of the plant
    func modifyPlantWateringChanges(withUID uID: UUID, newIrrigation irrigation: IrrigationInformation){
        //configure the fetchRequest
        let fetchRequest: NSFetchRequest<PlantEntity>
        fetchRequest = PlantEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", uID as CVarArg )
        fetchRequest.includesPropertyValues = false
        
        //craete a  WateredEntity to mofify
        let context = container.viewContext
        let Watered = WateredEntity(context: context)
        Watered.numberOfDays = irrigation.numberOfDays
        Watered.waterAmount = irrigation.waterAmount
        Watered.percentage = irrigation.percentage
        Watered.wasItWatered = irrigation.wasItWatered
        Watered.nextIrrigation = irrigation.nextIrrigation
        
        //modify the values of the context
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                object.watered = Watered
            }
            
        } catch {
            print("ERROR: \(error)")
        }
        
        do {
            try context.save()
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    
    
    //MARK: Remove all plants
    func deletePlants(){
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<PlantEntity> = PlantEntity.fetchRequest()
        let deleteBatch = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteBatch)
            print("Delete all Plants")
        } catch {
            print("Error Delete all Plants \(error)")
        }
    }
    
    
    //MARK: Delete a specific plant
    func deletePlant(_ plant: PlantEntity) {
        let context = container.viewContext
        context.delete(plant) /***delete Plant*/
        save()/***save the changes*/
    }
    
    
}
