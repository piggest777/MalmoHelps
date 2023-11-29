//
//  MonthlyReportViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import SwiftUI
import FirebaseFunctions
import Combine

class MonthlyReportViewModel: ObservableObject {
    @Published var monthlyParticipantList: [ParticipantReport] = []
    @Published var monthlyActivitiesList: [ActivityReport] = []
    @Published var isLoading = false
    @Published var updateDate: Date?
    @Published var reportType: MonthlyReportType = .participantsReport
    @Published var showAlert: Bool = false
    var errorText = ""
    
    var cancellables = Set<AnyCancellable>()
    
    var resultString: String = ""
    
    func getMonthlyRapport(for month: Int, year: Int) {
        
        isLoading = true
        
        switch reportType {
        case .participantsReport:
            FirFunctionManager.shared.generateReport(month: month, year: year)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                        self.errorText = "Error: \(error)"
                        self.showAlert = true
                        self.isLoading = false
                    }
                }, receiveValue: { report in
                    self.isLoading = false
                    let csvString = self.convertParticipantsToCSV(from: report.sorted(by: {$0.participantSurname < $1.participantSurname}))
                    do {
                        try self.saveCSV(csvFile: csvString, month: month, year: year)
                    } catch (let error) {
                        print("Can't save CSV: \(error.localizedDescription)")
                    }
                    self.loadReport(month: month, year: year)
                })
                .store(in: &cancellables)
        case .activitiesReport:
            FirFunctionManager.shared.calculateActivityHours(month: month, year: year)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                        self.isLoading = false
                    }
                }, receiveValue: { report in
                    self.isLoading = false
                    let csvString = self.convertActivitiesToCSV(from: report.sorted(by: {$0.activityName < $1.activityName}))
                    do {
                        try self.saveCSV(csvFile: csvString, month: month, year: year)
                    } catch (let error) {
                        print("Can't save CSV: \(error.localizedDescription)")
                    }
                    self.loadReport(month: month, year: year)
                })
                .store(in: &cancellables)
        }
    }
        
    func convertParticipantsToCSV(from reports: [ParticipantReport]) -> String {
        var result = "Participant ID,Participant Name,Participant Surname,Total Hours,Personal Number,ABF Region,City,Gender\n"
        for report in reports {
            result += report.toCSV() + "\n"
        }
        return result
    }
    
    func convertActivitiesToCSV(from reports: [ActivityReport]) -> String {
        var result = "Activity ID, Activities Name,Person in charge,Venue,Total Hours\n"
        for report in reports {
            result += report.toCSV() + "\n"
        }
        return result
    }
    
    func saveCSV(csvFile: String , month: Int, year: Int) throws {
        let fileURL = getFileUrl(month: month, year: year)
        try csvFile.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func loadReport(month: Int, year: Int) {
        let url = getFileUrl(month: month, year: year)
        guard let csvString = try? String(contentsOf: url) else  { return }
        switch reportType {
        case .participantsReport:
            guard let report = csvToParticipantsReports(csv: csvString) else { return }
            monthlyParticipantList = report
        case .activitiesReport:
            guard let report = csvToActivitiesReports(csv: csvString) else { return }
           monthlyActivitiesList = report
        }
        updateDate = updateDateOf(file: url)
    }
    
    func getFileUrl(month: Int, year: Int) -> URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return  directoryURL.appendingPathComponent("\(reportType.rawValue) report \(month) \(year)").appendingPathExtension("csv")
    }
    
    func updateDateOf(file: URL) -> Date? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
            return fileAttributes[.modificationDate] as? Date
        } catch {
            print("Error reading file attributes: \(error)")
            return nil
        }
    }
    
    func csvToParticipantsReports(csv: String) -> [ParticipantReport]? {
        var reports: [ParticipantReport] = []

        let rows = csv.components(separatedBy: "\n")
        guard rows.count > 1 else { return nil } // Ensure there's more than just the header

        for i in 1..<rows.count {
            let row = rows[i]
            let components = row.components(separatedBy: ",")
            guard components.count == 8 else { continue }

            let report = ParticipantReport(
                participantId: components[0],
                participantName: components[1],
                participantSurname: components[2],
                totalHours: Double(components[3]) ?? 0.0,
                personalNumber: components[4],
                region: components[5],
                city: components[6],
                gender: components[7]
            )

            reports.append(report)
        }

        return reports.sorted(by: {$0.participantSurname < $1.participantSurname})
    }
    
    func csvToActivitiesReports(csv: String) -> [ActivityReport]? {
        var reports: [ActivityReport] = []

        let rows = csv.components(separatedBy: "\n")
        guard rows.count > 1 else { return nil } // Ensure there's more than just the header

        for i in 1..<rows.count {
            let row = rows[i]
            let components = row.components(separatedBy: ",")
            guard components.count == 5 else { continue }

            let report = ActivityReport(
                activityId: components[0],
                activityName: components[1],
                personInCharge: components[2],
                venue: components[3],
                totalHours: Double(components[4]) ?? 0.0
            )

            reports.append(report)
        }

        return reports.sorted(by: {$0.activityName < $1.activityName})
    }


    
    func saveToTemporaryDirectory(csv: String, filename: String) -> URL? {
        let path = NSTemporaryDirectory().appending(filename)
        let url = URL(fileURLWithPath: path)
        
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Failed to write CSV data to file: \(error)")
            return nil
        }
    }
}

