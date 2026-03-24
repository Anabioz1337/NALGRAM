import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext
import DebugSettingsUI

private final class NALgramSettingsControllerArguments {
    let updateGhostMode: (Bool) -> Void
    let updateHideStories: (Bool) -> Void
    let updateHideSponsoredMessages: (Bool) -> Void
    let updateQuickReaction: (Bool) -> Void
    let openAppIconSettings: () -> Void
    let openDebugTools: () -> Void

    init(
        updateGhostMode: @escaping (Bool) -> Void,
        updateHideStories: @escaping (Bool) -> Void,
        updateHideSponsoredMessages: @escaping (Bool) -> Void,
        updateQuickReaction: @escaping (Bool) -> Void,
        openAppIconSettings: @escaping () -> Void,
        openDebugTools: @escaping () -> Void
    ) {
        self.updateGhostMode = updateGhostMode
        self.updateHideStories = updateHideStories
        self.updateHideSponsoredMessages = updateHideSponsoredMessages
        self.updateQuickReaction = updateQuickReaction
        self.openAppIconSettings = openAppIconSettings
        self.openDebugTools = openDebugTools
    }
}

private enum NALgramSettingsSection: Int32 {
    case features
    case appearance
    case tools
    case about
}

private enum NALgramSettingsEntry: ItemListNodeEntry {
    case featuresHeader
    case ghostMode(Bool)
    case hideStories(Bool)
    case hideSponsoredMessages(Bool)
    case quickReaction(Bool)
    case featuresFooter

    case appearanceHeader
    case appIcon

    case toolsHeader
    case debugTools
    case toolsFooter

    case aboutHeader
    case aboutText

    var section: ItemListSectionId {
        switch self {
        case .featuresHeader, .ghostMode, .hideStories, .hideSponsoredMessages, .quickReaction, .featuresFooter:
            return NALgramSettingsSection.features.rawValue
        case .appearanceHeader, .appIcon:
            return NALgramSettingsSection.appearance.rawValue
        case .toolsHeader, .debugTools, .toolsFooter:
            return NALgramSettingsSection.tools.rawValue
        case .aboutHeader, .aboutText:
            return NALgramSettingsSection.about.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .featuresHeader:
            return 0
        case .ghostMode:
            return 1
        case .hideStories:
            return 2
        case .hideSponsoredMessages:
            return 3
        case .quickReaction:
            return 4
        case .featuresFooter:
            return 5
        case .appearanceHeader:
            return 6
        case .appIcon:
            return 7
        case .toolsHeader:
            return 8
        case .debugTools:
            return 9
        case .toolsFooter:
            return 10
        case .aboutHeader:
            return 11
        case .aboutText:
            return 12
        }
    }

    static func <(lhs: NALgramSettingsEntry, rhs: NALgramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! NALgramSettingsControllerArguments

        switch self {
        case .featuresHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "Ayu Features",
                sectionId: self.section
            )
        case let .ghostMode(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "Ghost Mode",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateGhostMode(value)
                }
            )
        case let .hideStories(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "Hide Stories",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateHideStories(value)
                }
            )
        case let .hideSponsoredMessages(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "Hide Sponsored Messages",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateHideSponsoredMessages(value)
                }
            )
        case let .quickReaction(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "Quick Reactions",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateQuickReaction(value)
                }
            )
        case .featuresFooter:
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain("Ghost Mode suppresses read actions. Hide Stories changes the chat list header and takes effect after restarting the app. Sponsored messages update after reopening chats."),
                sectionId: self.section
            )
        case .appearanceHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "Appearance",
                sectionId: self.section
            )
        case .appIcon:
            return ItemListDisclosureItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "App Icon",
                label: "",
                sectionId: self.section,
                style: .blocks,
                action: {
                    arguments.openAppIconSettings()
                }
            )
        case .toolsHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "Tools",
                sectionId: self.section
            )
        case .debugTools:
            return ItemListDisclosureItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: "Advanced Debug Tools",
                label: "",
                sectionId: self.section,
                style: .blocks,
                action: {
                    arguments.openDebugTools()
                }
            )
        case .toolsFooter:
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain("This keeps the full Telegram iOS debug screen available for deeper experiments and regression checks."),
                sectionId: self.section
            )
        case .aboutHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "About",
                sectionId: self.section
            )
        case .aboutText:
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain("NALGRAM is the iOS fork baseline with the first AyuGram-style features ported into Telegram iOS."),
                sectionId: self.section
            )
        }
    }
}

private func nalgramSettingsControllerEntries(settings: ExperimentalUISettings) -> [NALgramSettingsEntry] {
    return [
        .featuresHeader,
        .ghostMode(settings.skipReadHistory),
        .hideStories(settings.hideStories),
        .hideSponsoredMessages(settings.hideSponsoredMessages),
        .quickReaction(!settings.disableQuickReaction),
        .featuresFooter,
        .appearanceHeader,
        .appIcon,
        .toolsHeader,
        .debugTools,
        .toolsFooter,
        .aboutHeader,
        .aboutText
    ]
}

public func nalgramSettingsController(context: AccountContext) -> ViewController {
    var pushControllerImpl: ((ViewController) -> Void)?

    let arguments = NALgramSettingsControllerArguments(
        updateGhostMode: { value in
            let _ = updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                var settings = settings
                settings.skipReadHistory = value
                return settings
            }).start()
        },
        updateHideStories: { value in
            let _ = updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                var settings = settings
                settings.hideStories = value
                return settings
            }).start()
        },
        updateHideSponsoredMessages: { value in
            let _ = updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                var settings = settings
                settings.hideSponsoredMessages = value
                return settings
            }).start()
        },
        updateQuickReaction: { value in
            let _ = updateExperimentalUISettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
                var settings = settings
                settings.disableQuickReaction = !value
                return settings
            }).start()
        },
        openAppIconSettings: {
            pushControllerImpl?(themeSettingsController(context: context, focusOnItemTag: .icon))
        },
        openDebugTools: {
            pushControllerImpl?(debugController(sharedContext: context.sharedContext, context: context))
        }
    )

    let signal = combineLatest(
        context.sharedContext.presentationData,
        context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.experimentalUISettings])
    )
    |> deliverOnMainQueue
    |> map { presentationData, sharedData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let settings = sharedData.entries[ApplicationSpecificSharedDataKeys.experimentalUISettings]?.get(ExperimentalUISettings.self) ?? ExperimentalUISettings.defaultSettings

        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("NALGRAM"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: nalgramSettingsControllerEntries(settings: settings),
            style: .blocks,
            animateChanges: true
        )

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] nextController in
        controller?.push(nextController)
    }
    return controller
}
