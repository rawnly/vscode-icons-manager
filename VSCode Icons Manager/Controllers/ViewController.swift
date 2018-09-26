//
//  ViewController.swift
//  VSCode Icons Manager
//
//  Created by Federico Vitale on 26/09/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Cocoa
import Foundation
import DockProgress

struct Item: Decodable {
    var name: String
    var title: String
    var image: String
    var download: String
}


extension NSUserInterfaceItemIdentifier {
    static let collectionViewItem = NSUserInterfaceItemIdentifier("CollectionViewItem")
}



class ViewController:
    NSViewController,
    NSCollectionViewDelegate,
    NSCollectionViewDataSource
{

    @IBOutlet weak var colView: NSCollectionView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    
    var appPath = "/Applications/Visual Studio Code.app";
    var icons = [Item]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DockProgress.style = .circle(radius: 55, color: .systemBlue)
        
        if ( !FileManager.default.fileExists(atPath: appPath))
        {
            print("NO VSCODE FOUND")
            let _ = dialogOKCancel(question: "Error!", text: "VSCode not found! App will terminate.")
            NSApplication.shared.terminate(self);
        }
        
        spinner.startAnimation(self)

        fetchIcons();
        
        let item = NSNib(nibNamed: "CollectionViewItem", bundle: nil)
        
        colView.register(item, forItemWithIdentifier: .collectionViewItem)
        
        colView.delegate = self
        colView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.icons.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath) as! CollectionViewItem;
        
        if ( self.icons.count > 0 ) {
            let image: NSImage = NSImage(contentsOf: URL(string: self.icons[indexPath[1]].image)!)!;
            item.img!.image = image;
        }
        
        return item;
        
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let i = indexPaths.first![1];
        let icon = self.icons[i];
        
        let dialogOutput = dialogOKCancel(question: "Warning!", text: "Please backup your icon", style: .warning);
        
        if ( dialogOutput ) {
            downloadFile(icon: icon);
        }
    }
}


extension ViewController {
    func fetchIcons()
    {
        guard let url: URL = URL(string: "https://vscode-icons-server-xaixyietnj.now.sh") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                let icons = try JSONDecoder().decode([Item].self, from: data);
                
                self.icons = icons;
                
                DispatchQueue.main.async {
                    self.colView.reloadData()
                    self.spinner.stopAnimation(self)
                    NSApp.requestUserAttention(.criticalRequest)
                }
            } catch let jsonError {
                print("Error serializing", jsonError)
            }
            
            }.resume()
    }
    
    func dialogOKCancel(question: String, text: String, style: NSAlert.Style = .warning) -> Bool {
        let alert = NSAlert()
        
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .critical
        
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    func downloadFile(icon: Item)
    {
//        Get VSCODE Path
        let vscodePath = self.appPath
        
        DockProgress.progressValue = 0
        
//        Craete the icon path
        let iconPath = "\(vscodePath)/Contents/Resources/Code.icns";
        
//        Check if the icon exists, if not abort.
        if ( FileManager.default.fileExists(atPath: "/Applications/Visual Studio Code.app/Contents/Resources/Code.icns") == false )
        {
            return;
        }
        
        DockProgress.progressValue = 25
        
//        Delete the old icon
        do {
            try FileManager.default.removeItem(atPath: iconPath)
        } catch let err {
            print(err)
        }
        
        
        DockProgress.progressValue = 50
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: icon.download)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            DockProgress.progressValue = 75
            
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: iconPath)
                    print("Item copied..")
                
//                  Update the icon
                    let task = Process()
                    
                    task.launchPath = "/usr/bin/touch"
                    task.arguments = [vscodePath]
                    
                    task.launch()
                    
                    DockProgress.progressValue = 100
                    
                    NSApp.requestUserAttention(.criticalRequest)
                    
                    print("Touched")
                } catch (let writeError) {
                    print("Error creating a file \(iconPath) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        
        task.resume()
    }

}

