//
//  ViewController.swift
//  ListApp
//
//  Created by Irem Aliye Akman on 9.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView : UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        fetch()
    }
    
    
    
    @IBAction func didRemoveBarButtonItemTapped (_ sender: UIBarButtonItem){
        presentAlert(title: "Uyarı!",
                     message: "Liste içerisindeki tüm ögeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle:"Evet!",
                     cancelButtonTitle: "Vazgeç") {_ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for item in self.data {
                managedObjectContext?.delete(item)
            }
            try? managedObjectContext?.save()
            self.fetch()
            
            //self.data.removeAll()
            self.tableView.reloadData()
        }
    }
    @IBAction func didAddBarButtonItemTapped (_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    
    func presentAddAlert(){
        
        presentAlert(title: "Yeni eleman ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvaiable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                //self.data.append((text)!)
                
                //Veriyi tutmak için kod başlangıcı
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                listItem.setValue(text,
                                  forKey: "title")
                try? managedObjectContext?.save()
                self.fetch()
                //Veriyi tutmak için kod bitişi
                
                self.tableView.reloadData()
                
            }else {
                self.presentwarningAlert()
            }
        }
        )
        
    }
    
    func presentwarningAlert(){
        
        presentAlert(title: "Uyarı!",
                     message: "Liste elemanı boş olamaz",
                     cancelButtonTitle: "Tamam")
    }
    
    
    
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvaiable: Bool = false,
                      defaultButtonHandler:((UIAlertAction) -> Void)? = nil){
        
        alertController = UIAlertController (title: title,
                                             message: message,
                                             preferredStyle: preferredStyle)
        if defaultButtonTitle != nil{
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvaiable {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fectRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fectRequest)
        
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title" ) as? String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            // self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            
            self.presentAlert(title: "Düzenle",
                              message: nil,
                              defaultButtonTitle: "düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvaiable: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    
                    //self.data[indexPath.row] = text!
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                        
                        
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }else {
                    self.presentwarningAlert()
                }
            }
            )
        }
        
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return config
    }
}
