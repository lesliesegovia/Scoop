import Foundation
import Photos
import CoreLocation

@Observable
class PhotosService {
    
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    /// Request access to the user's photo library
    func requestAccess() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
    }
    
    /// photo metadata
    struct PhotoMetadata: Identifiable {
        let id: String
        let creationDate: Date?
        let location: CLLocation?
        let asset: PHAsset
    }
    
    /// Fetch photos taken within a date range
    func fetchPhotos(from startDate: Date, to endDate: Date) -> [PhotoMetadata] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        
        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var photos: [PhotoMetadata] = []
        result.enumerateObjects { asset, _, _ in
            let metadata = PhotoMetadata(
                id: asset.localIdentifier,
                creationDate: asset.creationDate,
                location: asset.location,
                asset: asset
            )
            photos.append(metadata)
        }
        
        return photos
    }
}
