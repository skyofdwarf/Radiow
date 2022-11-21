//
//  HomeViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift
import RxCocoa
import Combine
import Moya

enum HomeAction {
    case ready
    case tryFetchNextPage
}

enum HomeMutation {
    case fetching(Bool)
    case stations([RadioStation], reset: Bool)
    case pageOffset(Int)
    case hasNextPage(Bool)
}

enum HomeEvent {
    case coordinate(HomeCoordinator.Location)
}

extension HomeEvent: Coordinating {
    var location: HomeCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct HomeState {
    @Drived var fetching: Bool = false
    @Drived var stations: [RadioStation] = []
    
    var pageOffset = 0
    var hasNextPage = true
}

final class HomeViewModel: CoordinatingViewModel<HomeAction, HomeMutation, HomeEvent, HomeState> {
    let service: RadioService
    let player: Player
        
    init<C: Coordinator>(service: RadioService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.player = player
        
        super.init(coordinator: coordinator,
                   state: HomeState()
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .ready:
            return fetchPage(offset: 0)
        case .tryFetchNextPage:
            return fetchPage(offset: state.pageOffset + Constant.PageLimit)
        }
    }
        
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .stations(let stations, let reset):
            if reset {
                state.stations = stations
            } else {
                state.stations += stations
            }
        case .pageOffset(let offset):
            state.pageOffset = offset
        case .hasNextPage(let hasNextPage):
            state.hasNextPage = hasNextPage
        }
    }
}

extension HomeViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func fetchPage(offset: Int) -> Observable<Reaction> {
        guard !state.fetching, state.hasNextPage else {
            return .empty()
        }
        return Observable<Reaction>.create { [weak self] observer in
            self?.service.request(RadioBrowserTarget.mostVotedStations(offset: offset, limit: Constant.PageLimit), success: { (stationDTOs: [RadioBrowserStation]) in
                let hasNextPage = stationDTOs.count >= Constant.PageLimit
                let stations = stationDTOs.map(RadioStation.init(_:))
                observer.onNext(.mutation(.pageOffset(offset)))
                observer.onNext(.mutation(.hasNextPage(hasNextPage)))
                observer.onNext(.mutation(.stations(stations, reset: offset == 0)))
                observer.onCompleted()
            }, failure: {
                observer.onNext(.error($0))
                observer.onCompleted()
            })
            return Disposables.create()
        }
        .startWith(.mutation(.fetching(true)))
        .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
    }
}
