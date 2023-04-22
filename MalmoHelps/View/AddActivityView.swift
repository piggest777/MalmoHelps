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
    
    @State var activityNameValidation: Bool = true
    @State var personInChargeValidation = true
    @State var venueValidation = true
    
    @State private var isKeyboardVisible = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("ActivityView")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.leading, 20)
                    .font(.title)
                WideTextField(title: "Activity Name", placeholder: .required, validatorType: .required, input: $activityName, fieldValidation: $activityNameValidation)
                WideTextField(title: "Person in charge", placeholder: .optional, validatorType: .none, input: $personInCharge, fieldValidation: $personInChargeValidation)
                WideTextField(title: "Venue", placeholder: .optional, validatorType: .none, input: $venue, fieldValidation: $venueValidation)
                Spacer()
                if !isKeyboardVisible  {
                    Button {
                        if activityName.isEmpty {
                            viewModel.showAlert = true
                            viewModel.alertText = "Format don't satisfy requirements"
                            return
                        }
                        
                        let activity = ActivityEntry(activityName: activityName, venue: venue.isEmpty ? nil : venue , personInCharge: personInCharge.isEmpty ? nil : personInCharge)
                        
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
        .navigationTitle(Text("Create person"))
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

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityView(isPresented: .constant(true))
    }
}
