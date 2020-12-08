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
    @State var angle: Double = 0.0
    @State var isAnimating = false

    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    @EnvironmentObject var user: UserSettings
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
    @State var rotate: Bool = false
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
                    ForEach(days ?? []){ grid in
                        let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!) * CGFloat(user.scale)
                        let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days![days!.firstIndex(of: grid)! < days!.count - 1 ? days!.firstIndex(of: grid)! + 1 : days!.count - 1].startTime!)!) * CGFloat(user.scale)
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
                            )
                            Spacer()
                                .frame(height: CGFloat(abs(space)+1))
                        }
                        .font(.system(size: 5.5 * CGFloat(user.scale), weight: .regular, design: .rounded))
                    }
                    Spacer()
                }

                let allPeriods = storedPeriods.filter({
                    let date = calendar.component(.weekOfYear, from: $0.date!) == calendar.component(.weekOfYear, from: Date())
                    let notCancelled = $0.code != "cancelled"
                    return date && notCancelled
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
                                let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!) * CGFloat(user.scale)
                                let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: days[days.firstIndex(of: grid)! < days.count - 1 ? days.firstIndex(of: grid)! + 1 : days.count - 1].startTime!)!) * CGFloat(user.scale)
                                let periods = allDayPeriods.filter({
                                    let start = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))!
                                     let end = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
                                     return start && end
                                })
                                VStack{
                                    HStack{
                                        if !periods.isEmpty{
                                            ForEach(periods){ period in
                                                    VStack{
                                                        HStack{
                                                            ForEach(period.subjects){ su in
                                                                Text(su.name ?? "")
                                                                    .font(.system(size: 10 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                                                            }
                                                        }
                                                        HStack{
                                                            ForEach(period.rooms){ ro in
                                                                Text(ro.name ?? "")
                                                                    .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                                                            }
                                                        }
                                                        HStack{
                                                            ForEach(period.teachers){ te in
                                                                Text(te.name ?? "")
                                                                    .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                                                            }
                                                        }
                                                        HStack{
                                                            ForEach(period.classes){ kl in
                                                                Text(kl.name ?? "")
                                                                    .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                                                            }
                                                        }
                                                    }
                                                    .foregroundColor(period.subjects.isEmpty ? .primaryInvert : hexStringToUIColor(hex: period.subjects[0].foreColor!))
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: UIScreen.main.bounds.width*0.16/CGFloat(periods.count)-CGFloat((periods.count-1)), height: CGFloat(height))
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundColor(period.subjects.isEmpty ? .primary : hexStringToUIColor(hex: period.subjects[0].backColor!))
                                                    )
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: UIScreen.main.bounds.width*0.17, height: CGFloat(height+abs(space))+1)
                            }
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            Spacer()
                .frame(height:150)
        }
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        return TimetableView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}




