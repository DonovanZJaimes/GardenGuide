//
//  PlantDetailsController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation
//MARK: Delegate for PlantDetailsController
protocol PlantDetailsControllerDelegate: AnyObject {
    func obtainedPlantInformation()
}

//MARK: Controller for PlantDetailsView
 @MainActor class PlantDetailsController {
    var plantInformation: PlantInformation!
    var provider: PlantDetailsProviderProtocol
    weak var delegate: PlantDetailsControllerDelegate?
    
    init(provider: PlantDetailsProviderProtocol = PlantDetailsProvider(), delegate: PlantDetailsControllerDelegate) {
        self.provider = provider
        self.delegate = delegate
        #if DEBUG
        if MockManagerSingleton.shared.runAppWithMock {
            self.provider = PlantDetailsProviderMock()
        }
        #endif
    }
    
     //MARK: Methods for PlantDetailsViewController
     //Obtain information about a plant through the access Token
    func getPlantInformation(accessToken: String, name: String) async  {
        do {
            //Make a request to the network of type POST
            let plantInformation = try await provider.getPlantInformation(accessToken, name: name)
            self.plantInformation = plantInformation
            //Inform that the information is already available
            delegate?.obtainedPlantInformation()
        }catch {
            print(error)
        }
    }
    
     //Convert information from a plant to another type of model
    func getPlantInformationWithSuggestedPlant(_ suggestedPlant: SuggestedPlant) {
        //Move from one model to another
        let name = suggestedPlant.name
        let similarImages = suggestedPlant.similarImages
        let details = suggestedPlant.details
        self.plantInformation = PlantInformation(name: name, similarImages: similarImages, details: details)
        //Inform that the information is already available
        delegate?.obtainedPlantInformation()
    }
     
     //MARK: Methods for ButtonIconList
     //Return an array for the information of ButtonDetailsList
     func getButtonDetailsList() -> [DetailsButtonIcon]{
         let options = [
            DetailsButtonIcon(title: "Synonyms", icon: .text),
            DetailsButtonIcon(title: "Editable parts", icon: .editableParts),
            DetailsButtonIcon(title: "Watered", icon: .watered),
            DetailsButtonIcon(title: "Propagation methods", icon: .spread),
            DetailsButtonIcon(title: "Common names", icon: .list),
         ]
         return options
     }
     
     //MARK: Methods for ButtonDetailsViewController
     //Return the indicated information depending on the button
     func getButtonDetailsList(tag: Int) -> [String] {
         switch tag {
         case 0:
             let synonyms = plantInformation.details.synonyms ?? ["No synonyms available"]
             return synonyms
         case 1:
             let editableParts = plantInformation.details.edibleParts ?? ["No editable plant parts found"]
             return editableParts
         case 2:
             let maxWatered = plantInformation.details.watering?.max ?? 0
             let minWatered = plantInformation.details.watering?.min ?? 0
             let watered = [String(minWatered), String(maxWatered)]
             return watered
         case 3:
             var propagationMethods = plantInformation.details.propagationMethods ?? ["No propagation methods found"]
             if propagationMethods.count == 0 { propagationMethods = ["No propagation methods found"]}
             return propagationMethods
         default:
             let commonNames = plantInformation.details.commonNames ?? ["No common names found"]
             return commonNames
         }
     }
     
     //Send the title name of the selected button
     func getButtonTitle(tag: Int) -> String {
         switch tag {
         case 0:
             return "Synonyms"
         case 1:
             return "Editable parts"
         case 2:
             return "Watered"
         case 3:
             return "Propagation methods"
         default:
             return "Common names"
             
         }
     }
     
     //MARK: Favourite Plant on Firestore
     func favouritePlantIsKept(_ option: Bool, withName name: String, image: String, plant: FavouritePlant){
         Task {
             await makeMethodsForFirestoreCloud{
                 switch option {
                 case true:
                     await FirestoreAddData.shared.addPlantOfFavouritesToCloud(plant)
                 case false:
                     await FirestoreDeleteData.shared.deletePlantOfFavouritesToCloud(name)
                 }
             }
         }
     }
     
}
