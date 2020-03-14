//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 10.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks = DataManager.shared.fetchData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            let task = self.tasks[indexPath.row]
            self.tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DataManager.shared.delete(task)
        }
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            self.showAlert(withTitle: "Edit Task", message: "Enter new name", task: self.tasks[indexPath.row])
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
    }
}

// MARK: - Private methods
extension TaskListViewController {
    private func setupView() {
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        
        // Set title for navigation bar
        title = "Task List"
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(
                red: 21/255,
                green: 101/255,
                blue: 192/255,
                alpha: 194/255
            )
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addNewTask)
            )
            
            navigationController?.navigationBar.tintColor = .white
        }
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", message: "What do you want to do?")
    }
    
    private func showAlert(withTitle: String, message: String, task: Task? = nil) {
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        
        if task == nil {
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                DataManager.shared.save(taskName, with: { task in
                    self.tasks.append(task)
                    self.tableView.insertRows(
                        at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                        with: .automatic)
                })
            }
            alert.addAction(saveAction)
        }
        else {
            let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                
                DataManager.shared.edit(task!, with: taskName, with: { [weak self] editedTask in
                    if let taskIndex = self?.tasks.firstIndex(of: task!) {
                        self?.tasks[taskIndex] = editedTask
                        let cellIndex = IndexPath(row: taskIndex, section: 0)
                        self?.tableView.reloadRows(at: [cellIndex], with: .automatic)
                    }
                })
            }
            alert.addAction(editAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        
        alert.addTextField{ (textField) in
            textField.text = task?.name
        }
        
        present(alert, animated: true)
    }
}
