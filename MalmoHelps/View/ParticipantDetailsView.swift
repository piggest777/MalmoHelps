//
//  ParticipantDetails.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-19.
//

import SwiftUI
import Firebase

enum ReportType {
    case personReport
    case activityReport
    
    mutating func toggle() {
        switch self {
        case .personReport:
            self = .activityReport
        case .activityReport:
            self = .personReport
        }
    }
}

struct ParticipantDetailsView: View {
    let activity: ActivityEntry
    let reportType: ReportType
    @Binding var isViewPresented: Bool
    
    
    @ObservedObject var personViewModel: PersonDetailsViewModel
    @StateObject var viewModel = ParticipantDetailsViewModel()
    @EnvironmentObject var dateHelper: DateHelper
    @EnvironmentObject var activitiesVM: ActivitiesViewModel
    @State var isPdfViewerPresented: Bool  = false
    @State var shareListPresented: Bool = false
    @State var groupedRapport: Bool = false
    @State var isEditProfilePresented: Bool = false
    @State private var showDeletionAlert = false
    
    init(person: Person, activity: ActivityEntry, reportType: ReportType, isDetailsPresented: Binding<Bool>) {
        personViewModel =  PersonDetailsViewModel(person: person)
        self.activity = activity
        self.reportType = reportType
        self._isViewPresented = isDetailsPresented
    }
    
    var month: Int {
        dateHelper.date.monthAsInt()
    }
    
    var year: Int {
        dateHelper.date.yearAsInt()
    }
    
    var body: some View {
        VStack {
            switch reportType {
            case .personReport:
                titleText(titleText: "\(personViewModel.person.firstName) \(personViewModel.person.lastName)", subtitleText: personViewModel.person.personalNumber)
            case .activityReport:
                titleText(titleText: activity.activityName, subtitleText: "\(activity.venue ?? String()), \(activity.personInCharge ?? String())")
            }
            horizontalMenu()
                .padding(.horizontal, 10)
            AnimatedHideCalendar(currentDate: $dateHelper.date)
//            MonthPicker()
            
            registrationList()
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
            Spacer()
        }.onAppear{
            requestRegistrations()
            print(activitiesVM.activities.count)
            viewModel.activities = activitiesVM.activities
        }
        .onChange(of: month) { _ in
            requestRegistrations()
        }
        .sheet(isPresented: $isPdfViewerPresented, content: {
            PDFViewer(isPresented: $isPdfViewerPresented, presentShareList: $shareListPresented, pdfData: viewModel.pdfData)
        })
        .sheet(isPresented: $isEditProfilePresented, content: {
            AddPersonView(isPresented: $isEditProfilePresented, person: personViewModel.person, isEditMode: true, cities: activitiesVM.cities)
        })
        .onChange(of: shareListPresented, perform: { presented in
            if presented {
                prepareAndPresentShareSheet(reportType: reportType, shareListPresented: &shareListPresented)
            }
        })
        .onChange(of: isEditProfilePresented) { newValue in
            if newValue == false {
                guard !personViewModel.person.id.isEmpty else { return }
                FsService.shared.fetchParticipant(by: personViewModel.person.id)
                    .sink { result in
                        switch  result {
                        case .finished:
                            print("Successfully get participant")
                        case .failure(let error):
                            print("Can't update participant: \(error.description)")
                        }
                    } receiveValue: { participant in
                        personViewModel.person = participant
                    }.store(in: &viewModel.cancellables)
            }
        }

    }
    
    @ViewBuilder func titleText(titleText: String, subtitleText: String) -> some View {
        VStack {
            Text(titleText)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
            Text(subtitleText)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder func registrationList () -> some View {
        switch reportType {
        case .personReport:
            ScrollView {
                ForEach(viewModel.participantRegistrationList  , id: \.self) { registration in
                    ParticipantDetailsElement(title: registration.activityName, subtitle: registration.activityPersonInCharge, date: registration.timestamp.dateValue(), duration: registration.duration) {}
                }
            }
        case .activityReport:
            ScrollView {
                ForEach(viewModel.groupedRegistrations.keys.sorted(), id: \.self) { key in
                    Section(header: Text("\(key) \(dateHelper.date.monthName(format: "MMMM"))")) {
                        ForEach(viewModel.groupedRegistrations[key] ?? [], id: \.id) { registration in
                            ParticipantDetailsElement(title: registration.participantName, subtitle: nil, date: registration.timestamp.dateValue(), duration: registration.duration) { }
                        }
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder func horizontalMenu() -> some View {
        HStack {
            
            if reportType == .personReport {
                IconButton(iconName: "person.text.rectangle", text: "Profile") {
                    isEditProfilePresented = true
                }
            }
            IconButton(iconName: "doc.text.fill", text: "Rapport") {
                groupedRapport = false
                createDocument(grouped: groupedRapport)
                shareListPresented = true

            }
            if reportType == .personReport {
                IconButton(iconName: "doc.on.doc.fill", text: "Grouped") {
                    groupedRapport = true
                    createDocument(grouped: groupedRapport)
                    shareListPresented = true
                }
            }
            IconButton(iconName: "eye.fill", text: "Preview") {
                createDocument()
                isPdfViewerPresented = true
            }
            
//            if reportType == .personReport {
//                IconButton(iconName: "trash", text: "Remove", isDestractive: true) {
//                    self.showDeletionAlert = true
//                }.alert(isPresented: $showDeletionAlert) {
//                    deleteAlert()
//                }
//            }
            
                }
        .padding(.horizontal, 10)
    }
    
    // Define the alert
    func deleteAlert() -> Alert {
        Alert(
            title: Text("Warning"),
            message: Text("Are you sure you want to delete this participant's information? This action cannot be undone."),
            primaryButton: .destructive(Text("Delete"), action: deleteParticipant),
            secondaryButton: .cancel()
        )
    }
    
    func deleteParticipant() {
        let personId = personViewModel.person.id
        FsService.shared.removeParticipant(by: personId) { success in
            isViewPresented = false
        }
    }
    
    func requestRegistrations() {
        switch reportType {
        case .personReport:
            viewModel.getActivities(participantId: personViewModel.person.id, month: month, year: year)
        case .activityReport:
            viewModel.getParticipants(for: activity, month: month, year: year)
        }
    }
    
    func createDocument(grouped: Bool = false) {
        switch reportType {
        case .personReport:
            guard !viewModel.participantRegistrationList.isEmpty else { return }
            viewModel.createDocumentFor(person: personViewModel.person, for: month, year: year, showTypes: grouped)
        case .activityReport:
            guard !viewModel.groupedRegistrations.isEmpty else { return }
            viewModel.createDocumentFor(activity: activity, for: month, year: year)
        }
    }
    
    func showSharePDFDataSheet() {
        guard let pdfData = viewModel.pdfData else { return }
        
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = documentNameGenerator(reportType: reportType)
        let temporaryFileURL = temporaryFolder.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: temporaryFileURL)
            // your code
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                if completed {
                    shareListPresented = false
                } else {
                    // Handle cancellation of activity
                    shareListPresented = false
                }
            }
            
            UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        } catch {
            print(error)
        }
        

    }
    
    func prepareAndPresentShareSheet(reportType: ReportType, shareListPresented: inout Bool) {
        guard let pdfData = viewModel.pdfData else { return }

        do {
            let temporaryFileURL = try writePDFDataToTemporaryDirectory(pdfData, reportType: reportType)
            presentShareSheet(with: temporaryFileURL, shareListPresented: &shareListPresented)
        } catch {
            // handle error
            print(error)
        }
    }
    
    func writePDFDataToTemporaryDirectory(_ pdfData: Data, reportType: ReportType) throws -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = documentNameGenerator(reportType: reportType)
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        
        try pdfData.write(to: temporaryFileURL)
        
        return temporaryFileURL
    }

    func presentShareSheet(with fileURL: URL, shareListPresented: inout Bool) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            self.shareListPresented = false
        }
        
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func documentNameGenerator(reportType: ReportType) -> String {
        switch reportType {
        case .personReport:
            let firstName = personViewModel.person.firstName
            let firstLetterOfName = firstName[firstName.startIndex]
            let grouped = groupedRapport ? "grouped" : "activities"
            return "\(personViewModel.person.lastName)_\(firstLetterOfName)_\(grouped)_\(dateHelper.date.monthName()).pdf"
        case .activityReport:
            let components = [
                activity.activityName,
                activity.venue,
                activity.personInCharge,
                dateHelper.date.monthName(),
            ]
            let validComponents = components.compactMap { $0 }.filter { !$0.isEmpty }
            
            let fileName = validComponents.joined(separator: "_")
            return "\(fileName).pdf"
        }
    }
}

struct ParticipantDetailsView_Previews: PreviewProvider {
    static let selectedMonth = DateHelper()
    static let activitiesVM = ActivitiesViewModel()
    static var previews: some View {
        ParticipantDetailsView(person: dummyPerson, activity: dummyActivity, reportType: .activityReport, isDetailsPresented: .constant(true))
            .environmentObject(selectedMonth)
            .environmentObject(activitiesVM)
        ParticipantDetailsView(person: dummyPerson, activity: dummyActivity, reportType: .personReport, isDetailsPresented: .constant(true))
            .environmentObject(selectedMonth)
            .environmentObject(activitiesVM)
    }
}

struct MonthPicker: View {
    let months = DateFormatter().monthSymbols
    
    @EnvironmentObject var selectedMonth: DateHelper
    
    var body: some View {
        HStack {
            Button {
                if selectedMonth.index == 0 {
                    selectedMonth.index = months!.count-1
                } else {
                    selectedMonth.index -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            Picker(selection: $selectedMonth.index, label: Text("Month")) {
                ForEach(0 ..< months!.count) { index in
                    Text(months![index])
                        .tag(index)
                        .font(.largeTitle)
                }
            }
            .padding(.horizontal, 10)
            Button {
                if selectedMonth.index == 11 {
                    selectedMonth.index = 0
                } else {
                    selectedMonth.index += 1
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }.frame(maxWidth: .infinity)
        
    }
}


class DateHelper: ObservableObject {
    @Published var index: Int
    @Published var date: Date
    
    func stringValue () -> String {
        let months = DateFormatter().monthSymbols
        return  months![index]
    }
    
    init() {
        let currentMonth = Calendar.current.component(.month, from: Date()) - 1
        // Subtracting 1 since the monthSymbols array is 0-indexed
        index = currentMonth
        date = Date()
    }
}



