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
        calendar.firstWeekday = 2
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        HStack{
            VStack{
                Spacer()
                    .frame(height: 60)
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
//            ForEach(storedDays.filter({!$0.elements.isEmpty}).sorted{$0.number < $1.number}){ day in
//                HStack{
//                    Divider()
//                    VStack{
//                        Spacer().frame(height:70)
//                        Text(calendar.shortWeekdaySymbols[Int(day.number)-1])
//                            .frame(height:30)
//                            .font(.system(size: 23, weight: .semibold, design: .rounded))
//
//
//                        let days = day.elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
//
//
//                        ForEach(day.elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}){ grid in
//
//
//                            let periods = storedPeriods.filter({
//                                let day = calendar.component(.weekday, from: $0.date!) == day.number
//                                let date = calendar.component(.weekOfYear, from: $0.date!) == calendar.component(.weekOfYear, from: Date())
//                                let start = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))!
//                                let end = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
//                                let startsBeforeEnd = Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
//                                return start && end && startsBeforeEnd && day && date
//                            })
//
//                            let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!)
//                            let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days[days.firstIndex(of: grid)! < days.count - 1 ? days.firstIndex(of: grid)! + 1 : days.count - 1].startTime!)!)
//
//
//                            VStack{
//                                HStack{
//                                    if !periods.isEmpty{
//                                        ForEach(periods){ period in
//                                            if !period.subjects.isEmpty{
//                                                VStack{
//                                                    Text(period.subjects[0].name ?? "")
//                                                        .font(.system(size: 14, weight: .regular, design: .rounded))
//                                                    Text(period.rooms[0].name ?? "")
//                                                        .font(.system(size: 13, weight: .regular, design: .rounded))
//                                                }
//                                                .foregroundColor(hexStringToUIColor(hex: period.subjects[0].foreColor!))
//                                                .multilineTextAlignment(.center)
//                                                .frame(width: UIScreen.main.bounds.width*0.19, height: CGFloat(height))
//                                                .background(
//                                                    RoundedRectangle(cornerRadius: 3)
//                                                        .foregroundColor(hexStringToUIColor(hex: period.subjects[0].backColor!))
//                                                )
//                                            }
//                                        }
//                                    }
//                                    else{
//                                        Spacer()
//                                    }
//                                }
//                                Spacer()
//                                    .frame(height: abs(space)+1)
//                            }
//                            .frame(width: UIScreen.main.bounds.width*0.19, height: CGFloat(height+abs(space)+1))
//                            .fixedSize()
//                        }
//                        Spacer()
//                    }
//                }
//            }
        }
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        return TimetableView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}



