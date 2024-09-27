//
//  ReportView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import SwiftUI

enum MonthlyReportType: String, CaseIterable {
    case participantsReport = "Participants"
    case activitiesReport = "Activities"
}

struct ReportView: View {
    
    @ObservedObject var viewModel = MonthlyReportViewModel()
    @State private var isShareSheetShowing = false
    @State var urlArray: [Any] = []
    @State var date = Date()
    
    var month: Int {
        date.monthAsInt()
    }
    
    var year: Int {
        date.yearAsInt()
    }
    
    
    var body: some View {
        VStack {
            Picker("Select report type", selection: $viewModel.reportType) {
                ForEach(MonthlyReportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 10)
            AnimatedHideCalendar(currentDate: $date)
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    LottieView(name: "loading")
                        .frame(width: 200, height: 200)
                    Text("Report is loading, please keep app open. \n Loading time can be more that a minute")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                    Spacer()
                }
            } else {
                ScrollView {
                    switch viewModel.reportType {
                    case .participantsReport:
                        ForEach(viewModel.monthlyParticipantList, id: \.participantId) { person in
                            MonthlyReportElement(
                                title: "\(person.participantName) \(person.participantSurname)",
                                subtitle: person.personalNumber,
                                totalHours: person.totalHours)
                        }
                    case .activitiesReport:
                        ForEach(viewModel.monthlyActivitiesList, id: \.activityId) { activity in
                            MonthlyReportElement(
                                title: "\(activity.activityName), \(activity.venue)",
                                subtitle: activity.personInCharge,
                                totalHours: activity.totalHours)
                        }
                    }

                }
            }
            Spacer()
            Group {
                StandardButton(text: "Update", action: {
                    viewModel.getMonthlyRapport(for: month, year: year)
                })
                .disabled(viewModel.isLoading)
                if let date =  viewModel.updateDate?.toString(format: "MM-dd-yyyy HH:mm") {
                    Text("Updated: \(date)")
                }
            }
            .alert(viewModel.errorText, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }
            .navigationBarItems(trailing: Button(action: {
                showShareCSVSheet()
            }, label: { Image(systemName: "square.and.arrow.up").imageScale(.large).padding() }))
        }.onAppear {
            viewModel.loadReport(month: month, year: year)
        }.onChange(of: date, perform: { _ in
            viewModel.monthlyParticipantList.removeAll()
            viewModel.monthlyActivitiesList.removeAll()
            viewModel.updateDate = nil
            viewModel.loadReport(month: month, year: year)
        })
        .onChange(of: viewModel.reportType, perform: { _ in
            viewModel.updateDate = nil
            viewModel.loadReport(month: month, year: year)
        })
    }
    
    func showShareCSVSheet() {
        
//        if viewModel.monthlyParticipantList.isEmpty { 
//            return
//        }
        
        let url = viewModel.getFileUrl(month: date.monthAsInt(), year: date.yearAsInt())
        
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                if completed {
                    isShareSheetShowing = false
                } else {
                    // Handle cancellation of activity
                    isShareSheetShowing = false
                }
            }
            UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

#Preview {
    ReportView()
}
