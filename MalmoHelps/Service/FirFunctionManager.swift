//
//  FirFunctionManager.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import Foundation
import Firebase
import FirebaseFunctions
import Combine

class FirFunctionManager {
    
    static let shared = FirFunctionManager()
    
    func generateReport(month: Int, year: Int) -> Future<[ParticipantReport], Error> {
        return Future { promise in
            let functions = Functions.functions()
            functions.httpsCallable("generateReport").call(["month": month, "year": year]) { (result, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result?.data as? [[String: Any]],
                          let jsonData = try? JSONSerialization.data(withJSONObject: result, options: []) {
                    let decoder = JSONDecoder()
                    do {
                        let report = try decoder.decode([ParticipantReport].self, from: jsonData)
                        promise(.success(report))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    func calculateActivityHours(month: Int, year: Int) -> Future<[ActivityReport], Error> {
        return Future { promise in
            let functions = Functions.functions()
            functions.httpsCallable("calculateActivityHoursForPeriod").call(["startMonth": month, "startYear": year]) { (result, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result?.data as? [[String: Any]],
                          let jsonData = try? JSONSerialization.data(withJSONObject: result, options: []) {
                    let decoder = JSONDecoder()
                    do {
                        let report = try decoder.decode([ActivityReport].self, from: jsonData)
                        promise(.success(report))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
}
