//
//  RadioBrowserTarget.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import Moya

enum RadioBrowserTarget: TargetType {
    case allStations([SearchStationOptions])
    case searchStation([SearchStationOptions])
    
    case serverStats
    case serverConfig
    case serverMirror
    
    /// The target's base `URL`.
    var baseURL: URL { URL(string: "http://all.api.radio-browser.info")! }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .allStations: return "json/stations"
        case .searchStation: return "json/stations/search"
        case .serverStats: return "json/stats"
        case .serverConfig: return "json/config"
        case .serverMirror: return "json/servers"
        }
    }

    /// The HTTP method used in the request.
    var method: Moya.Method { .get }

    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case .allStations(let options), .searchStation(let options):
            let params = options.map(\.parameter).reduce(into: [:]) { acc, dict in
                acc.merge(dict) { $1 }
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType { .none }

    /// The headers to be used in the request.
    var headers: [String: String]? { nil }
}

extension RadioBrowserTarget {
    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data {
        switch self {
        case .allStations:
            return """
            [{"changeuuid":"610cafba-71d8-40fc-bf68-1456ec973b9d","stationuuid":"941ef6f1-0699-4821-95b1-2b678e3ff62e","serveruuid":null,"name":"Best FM","url":"http://stream.bestfm.sk/128.mp3","url_resolved":"http://stream.bestfm.sk/128.mp3","homepage":"http://bestfm.sk/","favicon":"","tags":"","country":"Slovakia","countrycode":"SK","iso_3166_2":null,"state":"","language":"","languagecodes":"","votes":1,"lastchangetime":"2022-11-01 08:42:32","lastchangetime_iso8601":"2022-11-01T08:42:32Z","codec":"MP3","bitrate":128,"hls":0,"lastcheckok":1,"lastchecktime":"2022-11-13 08:52:53","lastchecktime_iso8601":"2022-11-13T08:52:53Z","lastcheckoktime":"2022-11-13 08:52:53","lastcheckoktime_iso8601":"2022-11-13T08:52:53Z","lastlocalchecktime":"","lastlocalchecktime_iso8601":null,"clicktimestamp":"2022-11-13 06:13:16","clicktimestamp_iso8601":"2022-11-13T06:13:16Z","clickcount":47,"clicktrend":3,"ssl_error":0,"geo_lat":null,"geo_long":null,"has_extended_info":false}]
            """.data(using: .utf8) ?? Data()
        case .searchStation:
            return """
            [{"changeuuid":"0704ed25-95be-416f-a975-5732bd0e782c","stationuuid":"30afaa67-5f0d-4edb-9661-074b19098dfe","serveruuid":null,"name":"Asian World Radio Latina","url":"http://stream.zeno.fm/37hmxgfgzs8uv","url_resolved":"http://stream-54.zeno.fm/37hmxgfgzs8uv?zs=KcdQxTgsTY6Qgig-11YchQ","homepage":"https://www.facebook.com/As1anWorld","favicon":"","tags":"anime,corea,deportes,friki,japan,japon,k-pop,korea,kpop,mexico,music,musica,news,noticias,otaku,sports,vocaloid","country":"Mexico","countrycode":"MX","iso_3166_2":null,"state":"Ciudad de México","language":"español internacional,español mexico,spanish","languagecodes":"","votes":31,"lastchangetime":"2022-05-08 02:06:17","lastchangetime_iso8601":"2022-05-08T02:06:17Z","codec":"MP3","bitrate":0,"hls":0,"lastcheckok":1,"lastchecktime":"2022-11-12 11:21:53","lastchecktime_iso8601":"2022-11-12T11:21:53Z","lastcheckoktime":"2022-11-12 11:21:53","lastcheckoktime_iso8601":"2022-11-12T11:21:53Z","lastlocalchecktime":"","lastlocalchecktime_iso8601":null,"clicktimestamp":"2022-11-12 15:41:20","clicktimestamp_iso8601":"2022-11-12T15:41:20Z","clickcount":14,"clicktrend":2,"ssl_error":0,"geo_lat":19.432827116743898,"geo_long":-99.13315773010255,"has_extended_info":false}]
            """.data(using: .utf8) ?? Data()
        case .serverStats:
            return """
            {"supported_version":1,"software_version":"0.7.24","status":"OK","stations":33802,"stations_broken":456,"tags":9015,"clicks_last_hour":3386,"clicks_last_day":119130,"languages":334,"countries":212}
            """.data(using: .utf8) ?? Data()
        case .serverConfig:
            return """
            {"check_enabled":false,"prometheus_exporter_enabled":true,"pull_servers":["http://nl1.api.radio-browser.info","http://de1.api.radio-browser.info"],"tcp_timeout_seconds":10,"broken_stations_never_working_timeout_seconds":259200,"broken_stations_timeout_seconds":864000,"checks_timeout_seconds":864000,"click_valid_timeout_seconds":86400,"clicks_timeout_seconds":864000,"mirror_pull_interval_seconds":300,"update_caches_interval_seconds":300,"server_name":"at1.api.radio-browser.info","server_location":"netcup.de","server_country_code":"AT","check_retries":5,"check_batchsize":100,"check_pause_seconds":60,"api_threads":16,"cache_type":"redis","cache_ttl":60,"language_replace_filepath":"https://radiobrowser.gitlab.io/radiobrowser-static-data/language-replace.csv","language_to_code_filepath":"/etc/radiobrowser/language-to-code.csv"}
            """.data(using: .utf8) ?? Data()
        case .serverMirror:
            return """
            [{"ip":"2a0a:4cc0:0:db9:282b:91ff:fed0:ddea","name":"at1.api.radio-browser.info"},{"ip":"2a03:4000:37:42:c4fe:4cff:fea7:8941","name":"de1.api.radio-browser.info"},{"ip":"2001:19f0:5001:32a4:5400:2ff:fe37:75c2","name":"nl1.api.radio-browser.info"},{"ip":"89.58.16.19","name":"v22022045963187310.megasrv.de"},{"ip":"95.179.139.106","name":"nl1.api.radio-browser.info"},{"ip":"91.132.145.114","name":"de1.api.radio-browser.info"}]
            """.data(using: .utf8) ?? Data()
        }
    }
}