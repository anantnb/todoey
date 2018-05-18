//
//  ViewController.swift
//  todoey
//
//  Created by Anant Bhat on 14/05/18.
//  Copyright © 2018 Anant Bhat. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    //let defaults = UserDefaults.standard
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let newItem1 = Item()
//        newItem1.title = "Call Mike"
//        itemArray.append(newItem1)
//        
//        let newItem2 = Item()
//        newItem2.title = "Call Fred"
//        itemArray.append(newItem2)
//        
//        let newItem3  = Item()
//        newItem3.title = "Call Shirish"
//        itemArray.append(newItem3)
        // Do any additional setup after loading the view, typically from a nib.
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
//            itemArray = items
//        }
       loadItems()
    }

    //MARK - TableView datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        if itemArray[indexPath.row].done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
        
    }

    //MARK - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
      // context.delete(itemArray[indexPath.row])
      //  itemArray.remove(at: indexPath.row)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //saveData()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add items methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once user click Add Item button on our UIAlert
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.newRelationship = self.selectedCategory
            
            self.itemArray.append(newItem)
            //self.saveData()
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            //print(alertTextField.text)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        do {
            try context.save()
        }catch {
            print("Error saving Item, \(error)")
        }
        self.tableView.reloadData()
    }
//    func saveData(){
//        let encoder = PropertyListEncoder()
//        do {
//            let itemData = try encoder.encode(itemArray)
//            try itemData.write (to: dataFilePath!)
//        } catch {
//            print("Error encoding item array, \(error)")
//        }
//        tableView.reloadData()
//    }
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "newRelationship.catName MATCHES %@", selectedCategory!.catName!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error in fetching items, \(error)")
        }
        tableView.reloadData()
    }
}
extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems( predicate: predicate)
      
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error in fetching items, \(error)")
//        }
//        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
