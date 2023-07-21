import SwiftUI
import TodoListPackage

struct SwiftUIListView: View {
    
    let coreDataCache = CoreDataCache.shared
    
    let dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }()
    
    @State var itemsWithoutDone = [
        TodoItem(text: "Buy groceries", importance: .important, done: true)
    ]
    
    @State var itemsWithDone = [
        TodoItem(text: "Buy groceries", importance: .important),
        TodoItem(text: "Read a book", deadline: Date())
    ]
    
    @State var shouldShowDoneTasks = false
    @State var showNewDetailsVC = false
    
    @State private var selectedTask: TodoItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(Colors.backPrimary!)
                
                List {
                    Section(header: headerView()) {
                        ForEach(shouldShowDoneTasks ? itemsWithDone : itemsWithoutDone, id: \.id) { task in
                            
                            Button(action: {
                                selectedTask = task
                            }, label: {
                                cell(for: task)
                            })
                            .buttonStyle(.borderless)
                        }
                        Button(action: {
                            showNewDetailsVC.toggle()
                        }, label: {
                            Text("Новое")
                                .frame(minHeight: 37)
                                .font(Font(Fonts.body))
                                .foregroundColor(Color(Colors.labelTertiary!))
                                .padding(.leading, 38)
                        }).sheet(isPresented: $showNewDetailsVC, onDismiss: {
                            coreDataCache.loadFromCoreData()
                            itemsWithDone = coreDataCache.todoItems
                            itemsWithoutDone = itemsWithDone.filter { !$0.done }
                        }) {
                            TodoItemDetailsVCRepresentable()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .onAppear {
                    coreDataCache.loadFromCoreData()
                    itemsWithDone = coreDataCache.todoItems
                    itemsWithoutDone = itemsWithDone.filter{ $0.done == false }
                }
                .sheet(item: $selectedTask, onDismiss: {
                    coreDataCache.loadFromCoreData()
                    itemsWithDone = coreDataCache.todoItems
                    itemsWithoutDone = itemsWithDone.filter { !$0.done }
                }) { task in
                    TodoItemDetailsVCRepresentable(task: task)
                }
                VStack {
                    Spacer()
                    Button {
                        showNewDetailsVC.toggle()
                    } label: {
                        Image(uiImage: Images.add!)
                    }.sheet(isPresented: $showNewDetailsVC, onDismiss: {
                        coreDataCache.loadFromCoreData()
                        itemsWithDone = coreDataCache.todoItems
                        itemsWithoutDone = itemsWithDone.filter { !$0.done }
                    }) {
                        TodoItemDetailsVCRepresentable()
                    }
                    
                }
                
            }
            .navigationTitle("Мои дела")
            .background(Color(Colors.backPrimary!))
            .toolbarBackground(.white, for: .navigationBar)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Text("Выполнено — \((itemsWithDone.count) - (itemsWithoutDone.count))")
                .font(Font(Fonts.subhead))
                .foregroundColor(Color(Colors.labelTertiary!))
                .textCase(nil)
            Spacer()
            Button {
                shouldShowDoneTasks.toggle()
            } label: {
                Text(shouldShowDoneTasks ? "Скрыть" : "Показать")
                    .font(Font(UIFont.systemFont(ofSize: 15, weight: .bold)))
                    .textCase(nil)
            }
        }
        .padding(.top, -3)
        .padding(.bottom, 12)
        .padding(.horizontal, -7)
    }
    
    private func cell(for task: TodoItem) -> some View {
        HStack(spacing: 12) {
            Image(uiImage: task.done ? Images.radioButtonOn! : task.importance == .important ? Images.radioButtonHighPriority! : Images.radioButtonOff!)
            if !task.done {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 2) {
                        if task.importance == .important {
                            Image(uiImage: Images.priorityHigh!)
                        }
                        Text(task.text)
                            .font(Font(Fonts.body))
                            .foregroundColor((task.color != nil) ? Color(UIColor(hex: task.color!)!) : Color(Colors.labelPrimary!))
                    }
                    if task.deadline != nil {
                        HStack(spacing: 2) {
                            Image(uiImage: Images.calendar!)
                                .renderingMode(.template)
                                .tint(Color( Colors.labelTertiary!))
                            Text(dateFormatter.string(from: task.deadline!))
                                .font(Font(Fonts.subhead))
                                .foregroundColor(Color(Colors.labelTertiary!))
                        }
                    }
                }
            } else {
                Text(task.text)
                    .font(Font(Fonts.body))
                    .foregroundColor(Color(Colors.labelTertiary!))
                    .strikethrough()
            }
            Spacer()
            Image(uiImage: Images.chevron!)
        }
        .frame(minHeight: 37)
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return 38
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: {
                let newItem = task.copy(done: !task.done)
                coreDataCache.updateTodoItem(newItem)
                coreDataCache.loadFromCoreData()
                itemsWithDone = coreDataCache.todoItems
                itemsWithoutDone = itemsWithDone.filter { $0.done == false }
            }, label: {
                Image(systemName: "checkmark.circle.fill")
            }).tint(Color(Colors.colorGreen!))
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(action: {
                coreDataCache.removeTodoItem(withID: task.id)
                coreDataCache.loadFromCoreData()
                itemsWithDone = coreDataCache.todoItems
                itemsWithoutDone = itemsWithDone.filter { $0.done == false }
            }, label: {
                Image(systemName: "trash.fill")
            }).tint(Color(Colors.colorRed!))
            
            Button(action: {
                
            }, label: {
                Image(systemName: "info.circle.fill")
            }).tint(Color(Colors.colorGrayLight!))
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIListView()
    }
}

struct TodoItemDetailsVCRepresentable: UIViewControllerRepresentable {
    
    let task: TodoItem?
    
    init(task: TodoItem? = nil) {
        self.task = task
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let detailsVC = TodoItemDetailsViewController()
        if task != nil {
            detailsVC.currentTask = task
        }
        
        return detailsVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
