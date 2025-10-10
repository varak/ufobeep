import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private let appGroupIdentifier = "group.com.ufobeep.app"
    private let sharedMediaKey = "shareExtensionMedia"

    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedContent()
    }

    private func handleSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            close()
            return
        }

        // Process each shared item
        for provider in itemProviders {
            // Handle images
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (item, error) in
                    self?.processImageItem(item: item, error: error)
                }
                return
            }

            // Handle videos
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { [weak self] (item, error) in
                    self?.processVideoItem(item: item, error: error)
                }
                return
            }
        }

        // No supported items found
        close()
    }

    private func processImageItem(item: NSSecureCoding?, error: Error?) {
        guard error == nil else {
            print("Error loading image: \(error!)")
            close()
            return
        }

        var imageURL: URL?

        if let url = item as? URL {
            imageURL = url
        } else if let data = item as? Data {
            // Save data to temp file
            imageURL = saveDataToTempFile(data: data, ext: "jpg")
        } else if let image = item as? UIImage {
            // Convert UIImage to data and save
            if let data = image.jpegData(compressionQuality: 0.9) {
                imageURL = saveDataToTempFile(data: data, ext: "jpg")
            }
        }

        if let imageURL = imageURL {
            saveSharedMediaAndOpenApp(url: imageURL, type: "image")
        } else {
            close()
        }
    }

    private func processVideoItem(item: NSSecureCoding?, error: Error?) {
        guard error == nil else {
            print("Error loading video: \(error!)")
            close()
            return
        }

        if let url = item as? URL {
            saveSharedMediaAndOpenApp(url: url, type: "video")
        } else {
            close()
        }
    }

    private func saveDataToTempFile(data: Data, ext: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "share_\(UUID().uuidString).\(ext)"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving temp file: \(error)")
            return nil
        }
    }

    private func saveSharedMediaAndOpenApp(url: URL, type: String) {
        // Save the media info to shared container
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            let mediaInfo: [String: Any] = [
                "url": url.path,
                "type": type,
                "timestamp": Date().timeIntervalSince1970
            ]
            sharedDefaults.set(mediaInfo, forKey: sharedMediaKey)
            sharedDefaults.synchronize()
        }

        // Open main app with deep link
        let deepLinkURL = URL(string: "ufobeep://share/media?type=\(type)")!

        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(deepLinkURL, options: [:]) { [weak self] success in
                    if success {
                        print("Successfully opened main app")
                    }
                    self?.close()
                }
                return
            }
            responder = responder?.next
        }

        // Fallback: try to open using extension context
        DispatchQueue.main.async { [weak self] in
            self?.extensionContext?.open(deepLinkURL) { success in
                print("Extension context open: \(success)")
                self?.close()
            }
        }
    }

    private func close() {
        DispatchQueue.main.async { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
