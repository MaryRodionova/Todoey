import UIKit
import CoreData
import ChameleonFramework


final class ToDoListViewController: SwipeTableViewController {

    private enum Layout {
        static let tableRowHeight: CGFloat = 80
        static let searchBarHeight: CGFloat = 44
    }

    var itemArray = [Item]()
    var filteredItems = [Item]()
    var selectedCategory: Categories? {
        didSet {
            loadItems()
        }
    }

    var isSearching = false

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func updateModel (at indexPath: IndexPath){
        let item = itemArray[indexPath.row]
        context.delete(item)
        itemArray.remove(at: indexPath.row)

        do {
            try context.save()
            print("Category deleted successfully from Core Data")
        } catch {
            print("Error deleting category: \(error)")
            itemArray.insert(item, at: indexPath.row)
        }
    }
}

// MARK: - Setup

private extension ToDoListViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = Layout.tableRowHeight

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            ToDoListTableViewCell.self,
            forCellReuseIdentifier: ToDoListTableViewCell.reuseId
        )
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        let searchBarAppearance = UISearchBar.appearance()

        if let colourHex = selectedCategory?.color {
            title = selectedCategory?.name

            if let navBarColour = UIColor(hexString: colourHex) {
                appearance.backgroundColor = navBarColour
                searchBarAppearance.backgroundColor = navBarColour
                searchBar.searchTextField.backgroundColor = .white
                navigationController?.navigationBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)

                appearance.largeTitleTextAttributes = [
                    .foregroundColor: ContrastColorOf(navBarColour, returnFlat: true),
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold)
                ]
            }
        }

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc
    func addButtonTapped() {
        var textField = UITextField()

        let alert = UIAlertController(
            title: "Add New Todoey Item",
            message: "",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? ""
            newItem.done = false
            newItem.parentCategory = self.selectedCategory

            self.itemArray.append(newItem)
            self.saveItems()
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true)
     }

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let categoryName = selectedCategory?.name else { return }

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension ToDoListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty ?? true {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? "")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
    }
}

// MARK: - UITableViewDataSource

extension ToDoListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredItems.count : itemArray.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoListTableViewCell.reuseId,
            for: indexPath
        ) as! ToDoListTableViewCell

        cell.delegate = self

        let item = isSearching ? filteredItems[indexPath.row] : itemArray[indexPath.row]
        cell.textLabel?.text = item.title

        if let colour = UIColor(
            hexString: (
                selectedCategory!.color
            )!
        )!.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }

        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ToDoListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = isSearching ? filteredItems[indexPath.row] : itemArray[indexPath.row]
        item.done.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
