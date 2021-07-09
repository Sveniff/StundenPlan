//
//  TimetableView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 06.10.20.
//
import CoreData
import SwiftUI
import Combine

struct TimetableView: View {
    @EnvironmentObject var user: UserData
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
    @FetchRequest(entity: Day.entity(), sortDescriptors: [])
    var storedDays: FetchedResults<Day>
    let TF = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    init(){
        TF.dateFormat = "H:mm"
        calendar.firstWeekday = 7
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        ScrollView{
            HStack{
                VStack{
                    let days = storedDays.isEmpty ? nil : storedDays[2].elements.sorted{
                        Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!
                    }
                    Spacer()
                        .frame(height: 100)
                    ForEach(days ?? []){ grid in
                        let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days![days!.firstIndex(of: grid)! < days!.count - 1 ? days!.firstIndex(of: grid)! + 1 : days!.count - 1].startTime!)!) * CGFloat(user.scale)
                        GridViewElement(grid, space)
                    }
                    Spacer()
                }
                .font(.system(size: 5.5 * CGFloat(user.scale), weight: .regular, design: .rounded))
                let allPeriods = storedPeriods.filter({
                    let date = calendar.component(.weekOfYear, from: $0.date!) == calendar.component(.weekOfYear, from: Date())
                    //let cancelled = $0.code == "cancelled"
                    return date //&& !cancelled
                }).sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                ForEach(storedDays.filter({!$0.elements.isEmpty}).sorted{$0.number < $1.number}){ day in
                    let allDayPeriods = allPeriods.filter({calendar.component(.weekday, from: $0.date!) == day.number})
                    VStack{
                        Text(calendar.shortWeekdaySymbols[Int(day.number)-1])
                            .frame(height:85)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                            let rows = allDayPeriods.map({$0.collisions}).max()
                        ForEach(allDayPeriods){ period in
                            let space = minutesBetweenDates(TF.date(from: period.endTime!)!, TF.date(from: allDayPeriods[allDayPeriods.firstIndex(of: period)! < allDayPeriods.count - 1 ? allDayPeriods.firstIndex(of: period)! + 1 : allDayPeriods.count - 1].startTime!)!) * CGFloat(user.scale)
                            PeriodView(period, space)
                        }
                        if allDayPeriods.count == 0{
                            EmptyView()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        return TimetableView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}




