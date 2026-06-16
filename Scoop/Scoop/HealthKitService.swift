import Foundation
import HealthKit

@Observable
class HealthKitService {
    
    private let healthStore = HKHealthStore()
    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    /// Request access to read step count data
    func requestAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device")
            return
        }
        
        let stepType = HKQuantityType(.stepCount)
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepType])
            await MainActor.run {
                self.authorizationStatus = healthStore.authorizationStatus(for: stepType)
            }
        } catch {
            print("HealthKit access error: \(error)")
        }
    }
    
    /// Fetch total step count within a date range
    func fetchStepCount(from startDate: Date, to endDate: Date) async -> Int {
        let stepType = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: stepType, predicate: predicate),
            options: .cumulativeSum
        )
        
        do {
            let result = try await descriptor.result(for: healthStore)
            let total = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            return Int(total)
        } catch {
            print("Step count fetch error: \(error)")
            return 0
        }
    }
}
