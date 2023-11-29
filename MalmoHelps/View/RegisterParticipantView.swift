//
//  RegisterParticipantView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-04.
//

import SwiftUI
import Firebase

struct RegisterParticipantView: View {
    var date: Date
    @Binding var activity: ActivityEntry
    @Binding var isPresented: Bool
    @ObservedObject var familiesLookUp: FamiliesLookupViewModel
    @ObservedObject var viewModel: RegisterParticipantViewModel
    @State var keyword = ""
    @State var keywordCalled = false
    
    @EnvironmentObject var actvitiesVM: ActivitiesViewModel
    
    init(date: Date, activity: Binding<ActivityEntry>, isPresented: Binding<Bool>, familiesLookUp: FamiliesLookupViewModel = FamiliesLookupViewModel(), keyword: String = "", keywordCalled: Bool = false) {
        viewModel = RegisterParticipantViewModel(registrationDay: date, activity: activity.wrappedValue)
        self.date = date
        self._activity = activity
        self._isPresented = isPresented
        self.familiesLookUp = familiesLookUp
        self.viewModel = viewModel
        self.keyword = keyword
        self.keywordCalled = keywordCalled
    }
    
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
    
    var isFav: Bool {
        guard let id = activity.id else { return false }
        return StorageManager.isFav(activityId: id)
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
                    if keyword.count > 2 {
                        familiesLookUp.keywordSubject.send((keyword, .person))
                    }
                    keywordCalled = true
                } else {
                    keywordCalled = false
                }
            }
        )
        
        NavigationView {
            VStack  {
                Text(Self.dateFormatter.string(from: date))
                    .font(.title)
                SearchBarView(keyword: keywordBinding, searching: $familiesLookUp.searching)
                ScrollView {
                    if !familiesLookUp.queryResultPerson.isEmpty {
                       ForEach (familiesLookUp.queryResultPerson,  id: \.id) { person in
                           PersonElement(person: person, date: date, activity: activity, showDuration: true) {
                               familiesLookUp.queryResultPerson.removeAll()
                               keyword = ""
                           }

                        }
                    }
                    else {
                        ForEach(viewModel.registeredParticipants, id: \.id) { person in
                            RegistrateElement(registredPerson: person) {
                                FsService.shared.removeRegistration(for: person)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }.navigationTitle(Text(activity.activityName))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .padding()
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            guard let id = activity.id else { return }
                            StorageManager.updateFavorite(activityID: id, isFavorite: !isFav)
                            actvitiesVM.updateFavoriteActivities()
                        } label: {
                            Image(systemName: isFav ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .imageScale(.medium)
                                .padding()
                        }
                    }
                }
        }
    }
}

struct RegisterParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterParticipantView(date: Date(), activity: .constant(ActivityEntry(id: "", activityName: "Dancing", venue: nil, personInCharge: "Victoria")), isPresented: .constant(true))
    }
}

struct RegistrateElement_Previews: PreviewProvider {
    static var previews: some View {
        RegistrateElement(registredPerson: Registration(participantName: "Denis", participantId: "1", year: 2023, month: 04, day: 10, duration: 1.0, timestamp: Timestamp(), activityName: "Dancing", activityPersonInCharge: "Victoria", venue: "Malmo", activityId: "1234567"), action: {print("Action")})
    }
}

struct RegistrateElement: View {
    let registredPerson: Registration
    let action: ()->Void
    
    var body: some View {
        HStack {
            Text(registredPerson.participantName)
                .padding(.leading, 10)
                .font(Font.headline.weight(.bold))
            Spacer()
            Button {
                action()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .tint(Color("DeleteColor"))
            }
            .padding(.trailing, 10)

        }
        .frame(height: 50)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 3)

        .overlay {
            RoundedRectangle(cornerRadius: 5)
            .stroke(Color.gray, lineWidth: 1)
        }        .padding(.horizontal)
    }
}

