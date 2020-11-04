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
    @FetchRequest(entity: Day.entity(), sortDescriptors: [])
    var storedDays: FetchedResults<Day>
    let TF = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    @State var selfIndexSideBar = 0
    init(){
        TF.dateFormat = "H:mm"
        calendar.firstWeekday = 2
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        HStack{
            VStack{
                Spacer()
                    .frame(height: 70)
                let days = storedDays[2].elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}
                ForEach(days){ grid in
                    let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!)
                    
                    let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: (try? days[selfIndexSideBar+1].startTime!) ?? grid.endTime!)!)
                    VStack{
                        HStack{
                            VStack{
                                Divider()
                                Spacer()
                                Divider()
                            }
                            .frame(width: UIScreen.main.bounds.width*0.03)
                            VStack{
                                Text(grid.startTime ?? "")
                                Spacer()
                                Text(grid.endTime ?? "")
                            }
                            .frame(width: UIScreen.main.bounds.width*0.07)
                            VStack{
                                Divider()
                                Spacer()
                                Divider()
                            }
                            .frame(width: UIScreen.main.bounds.width*0.03)
                        }
                        .frame(width: UIScreen.main.bounds.width*0.13, height: CGFloat(height))
                        Spacer()
                            .frame(height:space)
                    }
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .onAppear{
                        selfIndexSideBar += 1
                    }
                }
                .fixedSize()
                Spacer()
            }
            ForEach(storedDays.filter({!$0.elements.isEmpty}).sorted{$0.number < $1.number}){ day in
                HStack{
                    Divider()
                    VStack{
                        Spacer().frame(height:40)
                        Text(calendar.shortWeekdaySymbols[Int(day.number)-1])
                            .frame(height:30)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                        ForEach(day.elements.sorted{Int($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int($1.startTime!.replacingOccurrences(of: ":", with: ""))!}){ grid in
                            
                            let periods = storedPeriods.filter({
                                let day = calendar.component(.weekday, from: $0.date!) == day.number
                                let start = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))!
                                let end = Int16(grid.startTime!.replacingOccurrences(of: ":", with: ""))!...(Int16(grid.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
                                let startsBeforeEnd = Int16($0.startTime!.replacingOccurrences(of: ":", with: ""))! < Int16($0.endTime!.replacingOccurrences(of: ":", with: ""))!
                                return start && end && startsBeforeEnd && day
                            })
                            let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!)
                            HStack{
                                if !periods.isEmpty{
                                    ForEach(periods){ period in

                                        if !period.subjects.isEmpty{
                                            VStack{
                                                Text(period.subjects[0].name ?? "")
                                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                                Text(period.rooms[0].name ?? "")
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                            }
                                            .foregroundColor(hexStringToUIColor(hex: period.subjects[0].foreColor!))
                                            .frame(width: UIScreen.main.bounds.width*0.16, height: CGFloat(height))
                                            .multilineTextAlignment(.center)
                                            .background(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .foregroundColor(hexStringToUIColor(hex: period.subjects[0].backColor!))
                                            )
                                        }

                                    }
                                }
                                else{
                                    Spacer()
                                        .frame(width: UIScreen.main.bounds.width*0.16, height: CGFloat(height))
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width*0.165, height: CGFloat(height))
                            Spacer()
                                .frame(height:5)
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



