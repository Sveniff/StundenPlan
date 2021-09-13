//
//  TimetableView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 06.10.20.
//
import CoreData
import SwiftUI
import Combine

struct TimetableView: View, ViewInterface {
    @Environment(\.managedObjectContext) var managedObjectContext
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
    var presenter: TimetableViewPresenterViewInterface!
    @EnvironmentObject var env: TimetableViewEnvironment
    @ObservedObject var viewModel: TimetableViewViewModel

    let TF = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    init(presenter: TimetableViewPresenterViewInterface, viewModel: TimetableViewViewModel){
        self.presenter = presenter
        self.viewModel = viewModel
        TF.dateFormat = "H:mm"
        calendar.firstWeekday = 7
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        ScrollView{
            HStack{
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
                        ForEach(storedGrid){ grid in
                            let space = minutesBetweenDates(TF.date(from: grid.endTime!)!, TF.date(from: storedGrid[storedGrid.firstIndex(of: grid)! < storedGrid.count - 1 ? storedGrid.firstIndex(of: grid)! + 1 : storedGrid.count - 1].startTime!)!) * CGFloat(env.user.scale)
                            HStack{
                                ForEach(allDayPeriods.filter({$0.startTime! <= grid.endTime! && $0.endTime! >= grid.startTime!})){ period in
                                    PeriodView(period)
                                }
                            }
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
        let presenter = TimetableViewPresenter()
        let viewModel = TimetableViewViewModel()
        presenter.viewModel = viewModel
        return TimetableView(presenter: presenter, viewModel: viewModel)
    }
}




