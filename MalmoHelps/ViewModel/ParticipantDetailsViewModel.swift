//
//  ParticipantDetailsViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-19.
//

import Foundation
import SwiftUI
import Combine
import TPPDF


class ParticipantDetailsViewModel: ObservableObject {
    @Published var participantActivitiesList: [Registration] = []
    @Published var pdfData: Data?
    private var cancellables = Set<AnyCancellable>()
    
    func getActivities(participantId: String, month: Int, year: Int) {
        participantActivitiesList.removeAll()
        FsService.shared.getAllParticipantActivities(for: participantId, month: month, year: year)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching activities for partisipant: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { registrations in
                print(registrations)
                self.participantActivitiesList.append(contentsOf: registrations)
            }
            .store(in: &cancellables)
    }
    
    func getActivityTypes(from activities: [Registration]) -> [String] {
        var activityTypes = Set<String>()
        for activity in activities {
            activityTypes.insert(activity.activityName)
        }
        return Array(activityTypes)
    }
    
    func getNumberOfDays(for month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        guard let date = calendar.date(from: dateComponents) else { return 31 }

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numberOfDays = range.count
        return numberOfDays
    }
    
    func getFullMonthName(month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.monthSymbols[month - 1]
    }
    
    func getTotalHoursFor(for activities: [Registration]) -> Float {
        return activities.reduce(0.0) {$0 + $1.duration}
    }
    
//    func createTestPDF() {
//       pdfURL = PDFManager.shared.createTestPDF()
//    }
    
    func configTableChar()-> PDFTableCellStyle {
        let colors = (fill: UIColor.white, text: UIColor.black)
        let lineStyle = PDFLineStyle(type: .full, color: UIColor.black, width: 1)
        let borders = PDFTableCellBorders(left: lineStyle, top: lineStyle, right: lineStyle, bottom: lineStyle)
        let font = UIFont.systemFont(ofSize: 8)
        return PDFTableCellStyle(colors: colors, borders: borders, font: font)
    }
    func configureTableContent(for activity: String, numberOfDays: Int) -> [String?]  {
        let filteredActivities = participantActivitiesList.filter {
            $0.activityName == activity
        }
        let totalHours = getTotalHoursFor(for: filteredActivities)
        var rowContent:[String?] = []
        rowContent.append(activity)
        
        var activityDurations = [String?](repeating: nil, count: numberOfDays)
        
        for activity in filteredActivities {
            let index = activity.day - 1
            if activityDurations[index] != nil {
                let currentDuration = Float(activityDurations[index]!)
                if let currentDuration {
                    let sum = currentDuration + activity.duration
                    activityDurations[index] = String(sum)
                } else {
                    activityDurations[index] = String(activity.duration)
                }
            } else {
                activityDurations[index] = String(activity.duration)
            }
        }
        rowContent.append(contentsOf: activityDurations)
        rowContent.append(String(totalHours))
        return rowContent
    }
    
    func createDocumentFor(person: Person, for month: Int, year: Int) {
        var layout = PDFPageFormat.a4.layout
        layout.size = PDFPageFormat.a4.landscapeSize
        layout.margin.left = 10.0
        layout.margin.right = 20.0
        let document = PDFDocument(layout: layout)
        
        
        let personName = "\(person.firstName) \(person.lastName)"
        let personalNumber = person.personalNumber
        let phoneNumber = person.phoneNumber
        
        let font = UIFont.systemFont(ofSize: 36)
        let attributesTitle: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let attributesMonth: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24)
        ]
        let attributedMonth = NSMutableAttributedString(string: getFullMonthName(month: month), attributes: attributesMonth)
        
        let attributedTitle = NSMutableAttributedString(string: personName, attributes: attributesTitle)
        
        let attributesPhone: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .underlineStyle: NSUnderlineStyle.double.rawValue,
            .underlineColor: UIColor.black
        ]
        let attributedSubtitle = NSMutableAttributedString(string: "PN: \(personalNumber)  Phone number: \(phoneNumber)", attributes: attributesPhone)
        
        document.add(attributedText: attributedTitle)
        document.add(attributedText: attributedSubtitle)
        document.add(space: 10)
        document.add(attributedText: attributedMonth)
        document.add(space: 10)
        
        let activitiesArray = getActivityTypes(from: participantActivitiesList)
        let numberOfRow = activitiesArray.count
        let numberOfDays = getNumberOfDays(for: month, year: year)
        let numberOfColumns = numberOfDays + 2
        let table = PDFTable(rows: numberOfRow + 1, columns: numberOfColumns)
        let contentTableStyle = configTableChar()
        table.style = PDFTableStyle(footerCount: 0, rowHeaderStyle: contentTableStyle, columnHeaderStyle: contentTableStyle, contentStyle: contentTableStyle)
        table.widths[0] = 0.1
        
        for i in (0...numberOfColumns-1) {
            switch i {
            case 0:
                table.widths[i] = 0.075
            case numberOfColumns-1:
                table.widths[numberOfColumns-1] = 0.025
            default:
                table.widths[i] = (1.0-0.15)/CGFloat(numberOfDays)
            }
        }
        table.widths[numberOfDays+1] = 0.1
        let headerRow = table[row: 0]
        var headerRowArray: [String] = []
        headerRowArray.append("Activities")
        for i in (1...numberOfDays) {
            headerRowArray.append(String(i))
            
        }
        headerRowArray.append("Total")
        headerRow.content = headerRowArray
        for i in (1...activitiesArray.count) {
            table[row: i].content = configureTableContent(for: activitiesArray[i-1], numberOfDays: numberOfDays)
        }
        
        document.add(table: table)
        document.add(space: 30)
        
        let section = PDFSection(columnWidths: [0.1, 0.3, 0.075, 0.1,0.3])
        section.columns[0].add(.right, text: "ABF")
        section.columns[1].add(.left, text: "_________________")
        section.columns[2].add(.center, text: "        ")
        section.columns[3].add(.right, text: personName)
        section.columns[4].add(.left, text: "_________________")
        document.add(section: section)
        
        
        let generator = PDFGenerator(document: document)
        
        let pdfData = try? generator.generateData()
        self.pdfData = pdfData
    }
}
