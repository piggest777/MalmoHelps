//
//  AddActivityView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-22.
//

import SwiftUI
import Combine

struct AddActivityView: View {
    
    @StateObject var viewModel = AddActivityViewModel()
    @Binding var isPresented: Bool
    @State var activityName: String = ""
    @State var personInCharge: String = ""
    @State var venue: String = ""
    @State var duration: String = ""
    @State var activityType: ActivityType = .undefined
    
    @State var activityNameValidation = true
    @State var personInChargeValidation = true
    @State var venueValidation = true
    @State var durationValidation = true
    
    let activitiesTypes = ActivityType.allCases
    var activityPlaceholder = "Choose type"
    
    @State private var isKeyboardVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Activity Card")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.leading, 20)
                        .font(.title)
                    WideTextField(title: "Activity Name", placeholder: .required, validatorType: .required, input: $activityName, fieldValidation: $activityNameValidation)
                    WideTextField(title: "Person in charge", placeholder: .required, validatorType: .none, input: $personInCharge, fieldValidation: $personInChargeValidation)
                    WideTextField(title: "Venue", placeholder: .required, validatorType: .none, input: $venue, fieldValidation: $venueValidation)
                    WideTextField(title: "Default duration", placeholder: .required, validatorType: .float, input: $duration, fieldValidation: $durationValidation)
                    Menu {
                        ForEach(activitiesTypes, id: \.self){ type in
                            if type != .undefined {
                                Button("\(type.description)") {
                                    activityType = type
                                }
                            }
                        }
                        
                    } label: {
                        VStack(spacing: 5){
                            Divider()
                                .overlay(.black)
                            HStack{
                                Text("Activity Type")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                Text(activityType == .undefined ? activityPlaceholder : activityType.description)
                                    .foregroundColor(activityType == .undefined ? .gray : .black)
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.accentColor)
                                    .font(Font.system(size: 20, weight: .bold))
                                    .padding(.trailing, 5)
                            }
                            
                            .frame(height: 50)
                            Divider()
                                .overlay(.black)
                        }
                        .background(.white)
                        
                    }.padding(.vertical, 0)
                    Spacer()
                    if !isKeyboardVisible  {
                        Button {
                            if activityName.isEmpty ||
                                personInCharge.isEmpty ||
                                venue.isEmpty ||
                                duration.isEmpty ||
                                activityType == .undefined
                            {
                                viewModel.showAlert = true
                                viewModel.alertText = "Please fill all required fields"
                                return
                            }
                            
                            guard Float(duration) != nil else {
                                viewModel.showAlert = true
                                viewModel.alertText = "Check duration number format (use . instead of ,)"
                                return
                            }
                            
                            let activity = ActivityEntry(id: "", activityName: activityName, venue: venue.isEmpty ? nil : venue , personInCharge: personInCharge.isEmpty ? nil : personInCharge, defaultDuration: Float(duration), activityType: activityType.rawValue)
                            
                            viewModel.addNewActivity(activity)
                            
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12)
                                    .padding()
                            } else {
                                Text("Add".uppercased())
                                    .font(Font.headline.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.isPresented) { newValue in
                isPresented = newValue
            }
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.endEditing()})
            
            .alert(viewModel.alertText, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
            .navigationTitle(Text("Create activity"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .padding()
                    }
                }
            }
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityView(isPresented: .constant(true))
    }
}
