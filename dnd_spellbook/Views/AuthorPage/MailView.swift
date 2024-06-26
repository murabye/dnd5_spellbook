import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(
            presentation: Binding<PresentationMode>,
            result: Binding<Result<MFMailComposeResult, Error>?>
        ) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        vc.setToRecipients(["opelolen@gmail.com"])
        vc.setSubject("Список заклинаний")
        
        let deviceName = if ProcessInfo.processInfo.isiOSAppOnMac {
            "MacOS designed for iPad"
        } else {
            UIDevice.current.name
        }
        vc.setMessageBody(
            "Устройство: \(deviceName). Операционная система: \(UIDevice.current.systemVersion).",
            isHTML: false
        )

        return vc
    }
    
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {
        
    }
}
