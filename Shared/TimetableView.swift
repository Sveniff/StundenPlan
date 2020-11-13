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
                // Timegrid
                VStack{
                    Spacer()
                        .frame(height: 100)
                    let days = storedDays.isEmpty ? nil : storedDays[2].elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                    if days != nil{
                        ForEach(days!){ grid in
                            let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!)
                            let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days![days!.firstIndex(of: grid)! < days!.count - 1 ? days!.firstIndex(of: grid)! + 1 : days!.count - 1].startTime!)!)
                            VStack{
                                VStack{
                                    Text(grid.startTime ?? "")
                                    Text(grid.name ?? "")
                                        .font(.system(size: 18, weight: .regular, design: .rounded))
                                    Text(grid.endTime ?? "")
                                }
                                .frame(width: UIScreen.main.bounds.width*0.13, height: CGFloat(height))
                                .background(
                                    Rectangle()
                                        .foregroundColor(Color.secondary.opacity(0.1))
                                        .frame(width: UIScreen.main.bounds.width*0.1, height: CGFloat(height))
                                )
                                Spacer()
                                    .frame(height: CGFloat(abs(space)+1))
                            }
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                        }
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width*0.1, height: UIScreen.main.bounds.height)

                let allPeriods = storedPeriods.filter({
                    let date = calendar.component(.weekOfYear, from: $0.date!) == calendar.component(.weekOfYear, from: Date())
                    return date
                }).sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                ForEach(storedDays.filter({!$0.elements.isEmpty}).sorted{$0.number < $1.number}){ day in
                    let days = day.elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                    let allDayPeriods = allPeriods.filter({calendar.component(.weekday, from: $0.date!) == day.number})
                    HStack{
                        Divider()
                        VStack{
                            Spacer().frame(height:70)
                            Text(calendar.shortWeekdaySymbols[Int(day.number)-1])
                                .frame(height:30)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                            ForEach(day.elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}){ grid in
                                let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!)
                                let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days[days.firstIndex(of: grid)! < days.count - 1 ? days.firstIndex(of: grid)! + 1 : days.count - 1].startTime!)!)
                                let periods = allDayPeriods.filter({
                                    let start = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))!
                                    let end = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
                                    let overlapsStart = Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!
                                    let overlapsEnd = Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))! < Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
                                    return start || end || (overlapsStart && overlapsEnd)
                                })
                                VStack{
                                    HStack{
                                        if !periods.isEmpty{
                                            ForEach(periods){ period in
                                                PeriodView(period)
                                                    .frame(width: UIScreen.main.bounds.width*0.15/CGFloat(periods.count)-CGFloat((periods.count-1)*5), height: CGFloat(height))
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 3)
                                                            .foregroundColor(period.subjects.isEmpty ? .primary : hexStringToUIColor(hex: period.subjects[0].backColor!))
                                                    )
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: UIScreen.main.bounds.width*0.16, height: CGFloat(height+abs(space)+1))
                            }
                            Spacer()
                        }
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




