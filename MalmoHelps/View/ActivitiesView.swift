//
//  ActivitiesView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-19.
//

import SwiftUI

struct ActivitiesView: View {
    @State var showAddPerson: Bool = false
    @State var showAddActivity: Bool = false
    @StateObject var viewModel = ActivitiesViewModel()
    @ObservedObject var familiesLookUp = FamiliesLookupViewModel()
    @State var showSearchPersonView: Bool = false
    @State private var showPicker = false
    @State var selectedDate = Date()
    @State var changeDateByArrow = false
    @State var keyword = ""
    @State var keywordCalled = false
    @State var selectedActivity: ActivityEntry = ActivityEntry(id: "", activityName: "", venue: nil, personInCharge: nil)
    @State var navLinkActive = false
    @State var currPerson: Person?
    @State var calendarViewHeight = 40.0
    @StateObject private var selectedMonth = SelectedMonth()
    @State private var reportType: ReportType = .personReport
    @AppStorage("user_status") var userStatus: String = UNDEFINED
    
    @State var activityRepportNavLink: Bool = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    var body: some View {
        
        let keywordBinding = Binding<String>(
            get: {
                keyword
            },
            set: {
                if keywordCalled == false {
                    keyword = $0
                    familiesLookUp.queryResultPerson.removeAll()
                    familiesLookUp.fetchParticipants(keywords: keyword)
                    keywordCalled = true
                } else {
                    keywordCalled = false
                }
            }
        )
        
        NavigationView{
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if userStatus == ADMIN {
                        SearchBarView(keyword: keywordBinding, searching: $familiesLookUp.searching)
                    }

                    if familiesLookUp.queryResultPerson.isEmpty && keyword.isEmpty {
                        ZStack(alignment: .top) {
                            VStack {
                                Spacer().frame(height: calendarViewHeight + 10)
                                ScrollView{
                                    ForEach(viewModel.activities, id:\.id) { activity in
                                        ActivitiesElement(activity: activity, showSearchView: $showSearchPersonView, currActivity: $selectedActivity) {
                                            reportType = .activityReport
                                            selectedActivity = activity
                                            navLinkActive = true
                                            print("Actitity repport pressed for activity: \(selectedActivity.activityName)")
                                        }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                    }
                                }
                            }
                            calendarView()
                                .frame(maxHeight: calendarViewHeight)
                        }

                    } else {
                        ScrollView {
                            ForEach( familiesLookUp.queryResultPerson, id: \.id ) {
                                person in
                                
                                ParticipantListViewElement(person: person) {
                                    currPerson = person
                                    reportType = .personReport
                                    if currPerson != nil {
                                        navLinkActive = true
                                    }
                                }
                            }
                        }.padding(.horizontal)
                    }
                    Spacer()
                    NavigationLink(destination:  ParticipantDetailsView(person: currPerson ?? dummyPerson, activity: selectedActivity, reportType: reportType) , isActive: $navLinkActive) {
                       EmptyView()
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                showAddPerson.toggle()
            }, label: { Image(systemName: "person.fill.badge.plus").imageScale(.large).padding() }))
            .navigationBarItems(leading:  activityBarItems)
            .navigationTitle(Text("Activities"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(selectedMonth)
        .sheet(isPresented: $showAddPerson) {
            AddPersonView(isPresented: $showAddPerson)
        }.sheet(isPresented: $showSearchPersonView) {
            RegisterParticipantView(date: selectedDate, activity: $selectedActivity, isPresented: $showSearchPersonView)
        }
        .sheet(isPresented: $showAddActivity) {
            AddActivityView(isPresented: $showAddActivity)
        }
        .onChange(of: showAddActivity) { newValue in
            if newValue == false {
                viewModel.getActivities()
            }
        }
    }
    
    var activityBarItems: some View {
        Group {
            if userStatus == ADMIN {
                Button(action: {
                    showAddActivity.toggle()
                }, label: { Image(systemName: "note.text.badge.plus").imageScale(.large).padding() })
            }
        }
    }
    
    
    @ViewBuilder func calendarView() -> some View{
            HStack (alignment: .center) {
                Spacer()
                Button {
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)
                    selectedDate = yesterday!
                    changeDateByArrow = true
                } label: {
                    Image(systemName: "chevron.left")
                }
                Button {
                    withAnimation {
                        showPicker.toggle()
                        changeDateByArrow = false
                    }
                }  label: {
                    Text("\(selectedDate, formatter: dateFormatter)")
                        .padding(10)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray)
                        )
                }
                .background(
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .frame(width: 300, height: 300)
                        .clipped()
                        .background(Color.white.cornerRadius(10))
                        .opacity(showPicker ? 1 : 0 )
                        .offset(x: 0, y: 180)
                ).onChange(of: selectedDate) { newValue in
                    if !changeDateByArrow {
                        withAnimation {
                            showPicker.toggle()
                        }
                    }
                }
                Button {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)
                    selectedDate = tomorrow!
                    changeDateByArrow = true
                } label: {
                    Image(systemName: "chevron.right")
                }
                Spacer()
            }
    }
}


struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(viewModel: ActivitiesViewModel(activities: [ActivityEntry(id: "", activityName: "Dancing", venue: nil, personInCharge: "Denis")]))
    }
}
