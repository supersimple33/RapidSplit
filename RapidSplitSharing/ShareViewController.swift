//
//  ShareViewController.swift
//  RapidSplitSharing
//
//  Created by Addison Hanrattie on 11/18/25.
//

import UIKit
import Social
import UniformTypeIdentifiers

fileprivate let IMAGE_TYPE = UTType.image.identifier as String

fileprivate struct GroupFileManagerError: LocalizedError {
    let errorDescription: String? = "Could not open the group file manager."
}

class ShareViewController: SLComposeServiceViewController {

    override func viewWillAppear(_ animated: Bool) {
        // skip loading any views and go straight to app
        super.viewWillAppear(animated)
        self.didSelectPost()
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true // TODO: maybe some analysis here
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
        let provider = item.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        guard provider.hasItemConformingToTypeIdentifier(IMAGE_TYPE) else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        provider.loadItem(forTypeIdentifier: IMAGE_TYPE, options: nil) { [weak self] data, error in
            guard let self else { return }

            var imageData: Data?
            if let img = data as? UIImage {
                imageData = img.jpegData(compressionQuality: 0.95)
            } else if let url = data as? URL {
                imageData = try? Data(contentsOf: url)
            }

            guard let imageData else {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return
            }

            do {
                try self.saveImageDataToAppGroup(imageData)
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            } catch {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    }

    private func saveImageDataToAppGroup(_ data: Data) throws {
        guard let containerUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: GROUP_IDENTIFIER) else {

            throw GroupFileManagerError()
        }

        let fileUrl = containerUrl.appendingPathComponent(SHARED_IMAGE_FILE_NAME)
        try data.write(to: fileUrl)
        self.openMainApp()
    }

    private func openMainApp() {
        // Custom URL scheme – see next section
        let url = URL(string: "RapidSplit://" + OPEN_SHARED_IMAGE_PATH)!

        print("opening")

        var responder: UIResponder? = self
        while responder != nil {
            if let app = responder as? UIApplication {
                app.open(url, options: [:], completionHandler: nil)
                break
            }
            responder = responder?.next
        }
    }

}
