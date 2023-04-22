//
//  PDFViewer.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-21.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    @Binding var isPresented: Bool
    @State private var pdfDocument: PDFDocument?
    @Binding var presentShareList: Bool
    
    let pdfData: Data?
    
    var body: some View {
        NavigationView {
            if let pdfData  {
                ZStack {
                    PDFKitView(pdfData: pdfData)
    //                VStack {
    //                    Spacer()
    //                    StandardButton(text: "Create PDF") {
    //                        sharePDF()
    //                }
    //                }
                }.toolbar {
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
                
            } else {
                Text("Something goes wrong while fetching PDF Data")
            }
        }

    }

    func sharePDF() {
        isPresented = false
        presentShareList = true
//        guard let pdfData else { return }
//        let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
//        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    struct PDFKitView: UIViewRepresentable {
        let pdfData: Data
        
        func makeUIView(context: Context) -> PDFKitView.UIViewType {
            let pdfView = PDFView()
            pdfView.document = PDFDocument(data: pdfData)
            pdfView.autoScales = true
            return pdfView
        }
        
        func updateUIView(_ pdfView: PDFView, context: Context) {
            pdfView.document = PDFDocument(data: pdfData)
        }
    }
}


public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter({
                $0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}

