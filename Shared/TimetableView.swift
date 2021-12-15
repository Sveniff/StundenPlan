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
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var user: UserData
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
    
    init(){
        TF.dateFormat = "H:mm"
    }
    
    var body: some View {
        ScrollView{
            Spacer().frame(height: 300)
            HStack{
                ForEach(storedDays.filter({!$0.elements.isEmpty}).sorted{$0.number < $1.number}){ day in
                    VStack{
                        Text(user.calendar.shortWeekdaySymbols[Int(day.number)-1])
                            .frame(height:85)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                        ForEach(storedGrid.filter({$0.day!.number == day.number}).sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}){ grid in
                            let sortedGrid = storedGrid.filter({$0.day!.number == day.number}).sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                            let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!) * CGFloat(user.scale)
                            let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: sortedGrid[sortedGrid.firstIndex(of: grid)! < sortedGrid.count - 1 ? sortedGrid.firstIndex(of: grid)! + 1 : sortedGrid.count - 1].startTime!)!) * CGFloat(user.scale)
                            HStack{
                                let periods = periodsForElement(grid: grid)
                                if periods.isEmpty{
                                    Spacer()
                                }
                                else{
                                    ForEach(periods, id:\.self){ pe in
                                        PeriodView(pe)
                                    }
                                }
                            }.frame(height: height)
                                .overlay(
                                    VStack{
                                        Divider()
                                        Spacer()
                                        Divider()
                                    }
                                )
                            if space > 0{
                                Spacer().frame(height: space)
                            }
                        }
                    }
                }
            }
        }
    }
    private func periodsForElement(grid: GridElement) -> [Period]{
        var periods = storedPeriods.filter({
            let date = user.calendar.component(.weekOfYear, from: $0.date!) == user.calendar.component(.weekOfYear, from: Date())
            //let cancelled = $0.code == "cancelled"
            return date //&& !cancelled
        })
        periods.sort(by:{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!})
        periods = periods.filter({user.calendar.component(.weekday, from: $0.date!) == grid.day!.number})
        periods = periods.filter({$0.startTime! < grid.endTime! && $0.endTime! > grid.startTime!})
        return periods
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        return TimetableView()
    }
}
