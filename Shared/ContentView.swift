//
//ContentView.swift
//Shared
//
//Created by Sven Iffland on 25.08.20.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserData
    @FetchRequest(entity: Teacher.entity(), sortDescriptors: [])
    var storedTeachers: FetchedResults<Teacher>
    @FetchRequest(entity: Subject.entity(), sortDescriptors: [])
    var storedSubjects: FetchedResults<Subject>
    @FetchRequest(entity: BaseClass.entity(), sortDescriptors: [])
    var storedBaseClasses: FetchedResults<BaseClass>
    @FetchRequest(entity: Period.entity(), sortDescriptors: [])
    var storedPeriods: FetchedResults<Period>
    @FetchRequest(entity: Room.entity(), sortDescriptors: [])
    var storedRooms: FetchedResults<Room>
    @FetchRequest(entity: GridElement.entity(), sortDescriptors: [])
    var storedGrid: FetchedResults<GridElement>
    @FetchRequest(entity: Day.entity(), sortDescriptors: [])
    var storedays: FetchedResults<Day>
    
    @State private var showError = false
    @State var error: String = ""
    var body: some View {
        VStack{
            #if os(iOS)
                DashboardMobile()
                    .onAppear{
                        if (user.lastQuery?.addingTimeInterval(600)) ?? Date() <= Date(){
                            do{
                                try user.store()
                            }
                            catch{
                                self.error = error.localizedDescription
                                self.showError = true
                            }
                        }
                    }
                    .alert(isPresented: $showError, content: {
                        Alert(title: Text("Ein Fehler ist aufgetreten"), message: Text(error), dismissButton: .cancel())
                    })
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
