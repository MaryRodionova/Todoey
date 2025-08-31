import UIKit
import CoreData
import ChameleonFramework

final class CategoryTableViewController: SwipeTableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var categories = [Categories]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadCategories()
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }

    private func setupNavigationBar() {
        title = "Todoey"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .separator
        tableView.rowHeight = 80
        tableView.showsVerticalScrollIndicator = true

        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc
    private func addButtonTapped() {
        var textField = UITextField()

        let alert = UIAlertController(
            title: "Add New Category Item",
            message: "",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Add", style: .default) { _ in
            let newCategory = Categories(context: self.context)
            newCategory.name = textField.text ?? "New Category"
            newCategory.color = UIColor.randomFlat().hexValue()

            self.categories.append(newCategory)
            self.saveCategories()
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }

    private func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]
        context.delete(categoryToDelete)
        categories.remove(at: indexPath.row)
        
        do {
            try context.save()
            print("Category deleted successfully from Core Data")
        } catch {
            print("Error deleting category: \(error)")
            categories.insert(categoryToDelete, at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource

extension CategoryTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell  = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name

        guard let categoryColor = UIColor(hexString: category.color!) else { fatalError()}
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCategory = categories[indexPath.row]
        let detailVC = ToDoListViewController()
        detailVC.selectedCategory = selectedCategory
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
