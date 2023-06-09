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
    let person: Person
    let activity: ActivityEntry
    
    let reportType: ReportType

    @StateObject var viewModel = ParticipantDetailsViewModel()
    @EnvironmentObject var selectedMonth: SelectedMonth
    @State var isPdfViewerPresented: Bool  = false
    @State var shareListPresented: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20)
            switch reportType {
            case .personReport:
                titleText(titleText: "\(person.firstName) \(person.lastName)", subtitleText: person.personalNumber)
            case .activityReport:
                titleText(titleText: activity.activityName, subtitleText: "\(activity.venue ?? String()), \(activity.personInCharge ?? String())")
            }
            MonthPicker()

            regisrtartionList()
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
            
            Spacer()
        }.onAppear{
            requestRegistrations()
        }
        .onChange(of: selectedMonth.index) { _ in
            requestRegistrations()
        }
        .sheet(isPresented: $isPdfViewerPresented, content: {
            PDFViewer(isPresented: $isPdfViewerPresented, presentShareList: $shareListPresented, pdfData: viewModel.pdfData)
        })
        .onChange(of: shareListPresented, perform: { presented in
            if presented {
                guard let pdfData = viewModel.pdfData else { return }
                
                        let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
                        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }
        })
        .navigationBarItems(trailing: Button(action: {
            guard !viewModel.participantRegistrationList.isEmpty else { return }
            viewModel.createDocumentFor(person: person, for: selectedMonth.index + 1, year: 2023)
            shareListPresented = true
        }, label: { Image(systemName: "doc.text").imageScale(.large).padding() }))
        .navigationBarItems(trailing: Button(action: {
            
            switch reportType {
            case .personReport:
                guard !viewModel.participantRegistrationList.isEmpty else { return }
                viewModel.createDocumentFor(person: person, for: selectedMonth.index + 1, year: 2023)
            case .activityReport:
                guard !viewModel.groupedRegistrations.isEmpty else { return }
                viewModel.createDocumentFor(activity: activity, for: selectedMonth.index + 1, year: 2023)
            }
            isPdfViewerPresented = true
        }, label: { Image(systemName: "eye").imageScale(.large).padding() }))
    }
    
    @ViewBuilder func titleText(titleText: String, subtitleText: String) -> some View {
        VStack {
            Text(titleText)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
            Text(subtitleText)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder func regisrtartionList () -> some View {
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
                    Section(header: Text("\(key) \(selectedMonth.stringValue())")) {
                        ForEach(viewModel.groupedRegistrations[key] ?? [], id: \.id) { registration in
                            ParticipantDetailsElement(title: registration.participantName, subtitle: nil, date: registration.timestamp.dateValue(), duration: registration.duration) { }
                        }
                    }
                }
            }
        }
    }
    
    func requestRegistrations() {
        switch reportType {
        case .personReport:
            viewModel.getActivities(participantId: person.id, month: selectedMonth.index+1, year: 2023)
        case .activityReport:
            viewModel.getParticipants(for: activity, month: selectedMonth.index+1, year: 2023)
        }
    }
}

struct ParticipantDetailsView_Previews: PreviewProvider {
    static let selectedMonth = SelectedMonth()
    static var previews: some View {
        ParticipantDetailsView(person: Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: nil, personalNumber: "890908-5832", phoneNumber: "0768719691", customQrCode: nil, keywords: []), activity: dummyActivity, reportType: .activityReport).environmentObject(selectedMonth)
        ParticipantDetailsView(person: Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: nil, personalNumber: "890908-5832", phoneNumber: "0768719691", customQrCode: nil, keywords: []), activity: dummyActivity, reportType: .personReport).environmentObject(selectedMonth)
    }
}

struct MonthPicker: View {
    let months = DateFormatter().monthSymbols
    
    @EnvironmentObject var selectedMonth: SelectedMonth
    
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


class SelectedMonth: ObservableObject {
    @Published var index: Int
    
    func stringValue () -> String {
        let months = DateFormatter().monthSymbols
        return  months![index]
    }
    
    init() {
        let currentMonth = Calendar.current.component(.month, from: Date()) - 1
        // Subtracting 1 since the monthSymbols array is 0-indexed
        index = currentMonth
    }
}



