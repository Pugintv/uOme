//
//  ViewController.swift
//  uOme
//
//  Created by Victor Rosas on 10/12/18.
//  Copyright © 2018 Victor Rosas. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    //var names: [String] = []
    var people: [NSManagedObject] = []
    
    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default){
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else{
                    return
            }
            
            self.save(name:nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
       present(alert,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "The list"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //We need NSManagedObjectContext so we check for it
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // NSFetchRequest is responsible for fetching from Core Data.Fetches are like queries
        //in this case we fetch with all objects of entityName
        //We expect return type NSManagedObject
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //Managed Object Context executes the query
        //Returns array of NSManagedObjects with the criteria of fetch request
        
        do{
            people = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch \(error),\(error.userInfo)")
        }
    }

}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" ,for:indexPath)
        
        let person = people[indexPath.row]
        
        cell.textLabel?.text = person.value(forKeyPath:"name") as? String
        return cell
    }
    
    func save(name: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        //we need NSManagedObjectContext insert to context,then commit to disk
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create a new managed object and insert into managed object context
        //you can do in one step using entity(forEntityName: in:)
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //NSManagedObject set name using key-value
        
        person.setValue(name, forKey: "name")
        
        //Commit changes and save to disk using save,insert into array so it can show
        
        do{
            try managedContext.save()
            people.append(person)
        }catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
}

