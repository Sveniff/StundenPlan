//
//  TimetableView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 06.10.20.
//
import CoreData
import SwiftUI

struct TimetableView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
    @State var sortedPeriods: [Period] = []
    @State var sortedGrid: [GridElement] = []
    var body: some View {
        HStack{
            ForEach(Range(1...6)){ day in
                
            }
//            Spacer()
//            ForEach(Range(2...6)){ i in
//                HStack{
//                    Divider()
//                    VStack{
//                        Spacer()
//                            .frame(height: UIScreen.main.bounds.height/10)
//                        let periods = storedPeriods.filter({Calendar.current.component(.weekday, from: $0.date!) == i}).sorted{
//                            Int($0.startTime!)! < Int($1.startTime!)!
//                        }
//                        ForEach(periods){ period in
//                            if !period.subjects.isEmpty{
//                                VStack{
//                                    Text(period.subjects[0].name ?? "")
//                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
//                                    Text(period.rooms[0].name ?? "")
//                                        .font(.system(size: 13, weight: .light, design: .default))
//                                }
//                                .foregroundColor(hexStringToUIColor(hex: period.subjects[0].foreColor!))
//                                .frame(height: 20)
//                                .multilineTextAlignment(.center)
//                                .frame(width: UIScreen.main.bounds.width*0.17, height: 45)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .foregroundColor(hexStringToUIColor(hex: period.subjects[0].backColor!))
//                                )
//                                .padding(.vertical, 1)
//
//                            }
//                        }
//                        Spacer()
//                    }
//                    Divider()
//                }
//                .frame(width: UIScreen.main.bounds.width*0.175)
//            }
//            Spacer()
//            VStack{
//                Group{
//                    Text("07:50")
//                    Text("08:35")
//                    Text("08:40")
//                    Text("09:25")
//                }
//                Group{
//                    Text("09:45")
//                    Text("10:30")
//                    Text("10:35")
//                    Text("11:20")
//                }
//                Group{
//                    Text("11:40")
//                    Text("12:25")
//                    Text("12:30")
//                    Text("13:15")
//                }
//                Group{
//                    Text("13:25")
//                    Text("14:10")
//                }
//                Group{
//                    Text("14:15")
//                    Text("15:00")
//                    Text("15:05")
//                    Text("15:50")
//                }
//                Group{
//                    Text("15:55")
//                    Text("16:40")
//                    Text("16:40")
//                    Text("17:25")
//                }
//                Group{
//                    Text("17:25")
//                    Text("18:00")
//                }
//            }
//            .foregroundColor(.secondary)
//            .font(.system(size: 13, weight: .semibold, design: .rounded))
//            Divider()
        }
        .onAppear{
            sortedGrid = storedGrid.sorted(by:{
                var re = false
                if $0.day != $1.day{
                    re = $0.day!.number > $0.day!.number
                }
                else if Int($0.startTime!)! != Int($0.startTime!)!{
                    re = Int($0.startTime!)! > Int($0.startTime!)!
                }
                else{
                    re = Int($0.name!)! < Int($1.name!)!
                }
                return re
            })
        }
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        return TimetableView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
