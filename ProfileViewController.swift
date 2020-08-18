//
// mybox
// Copyright © 2020 Trinity Digital. All rights reserved.
//

import Reusable
import UIKit

protocol СommonProfileСellType {}

class ProfileViewController: ModalPresentableController {
    var userManager: UserManagerProtocol!

    var cellsVM: [СommonProfileСellType] = []

    @IBOutlet var buildVersionLabel: UILabel! {
        willSet {
            let number = ProjectConfiguration.current.appVersion
            newValue.text = "\(L10n.Profile.versionLabel) \(number)"
        }
    }

    @IBOutlet var betaDesignButton: UIButton!
    @IBOutlet var developmentButton: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: CardTableViewCell.self)
        tableView.register(cellType: SectionsTableViewCell.self)
        getData()
    }

    @IBAction private func designButtonAction(_: UIButton) {
        openLinkInSafari(PlistFiles.betaAgencyURL, with: self)
    }

    @IBAction private func developmentButtonAction(_: UIButton) {
        openLinkInSafari(PlistFiles.handhDevelopmentURL, with: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case var destination as DeliveryTypeModuleInput:
            destination.configuration = .addresses
        default:
            break
        }
    }

    func getData() {
        loadingIndication()
        userManager.fetchUser { [weak self] result in
            self?.hideIndication()
            switch result {
            case let .success(response):
                let user = response.data
                self?.cellsVM = [
                    CardCellVM(user: user),
                    SectionCellVM(name: L10n.Profile.adressNameCell, counter: nil, color: nil) {
                        self?.perform(segue: StoryboardSegue.Profile.addresses)
                    },
                    SectionCellVM(name: L10n.Profile.ordersNameCell, counter: 1, color: .orange) {
                        self?.perform(segue: StoryboardSegue.Profile.orders)
                    },
                    SectionCellVM(name: L10n.Profile.supportNameCell, counter: 2, color: .red) {
                        self?.perform(segue: StoryboardSegue.Profile.feedBack)
                    },
                    SectionCellVM(name: L10n.Profile.settingsNameCell, counter: nil, color: nil),
                ]
                self?.tableView.reloadData()
            case let .failure(error):
                self?.presentErrorAlert(error: error, retry: nil)
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        cellsVM.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = cellsVM[safe: indexPath.row] else {
            return UITableViewCell()
        }

        if let viewModel = viewModel as? CardCellVM {
            let cell = tableView.dequeueReusableCell(for: indexPath) as CardTableViewCell
            cell.tapOnQRcode = { [weak self] in self?.perform(segue: StoryboardSegue.Profile.qrcode) }
            cell.viewModel = viewModel
            return cell
        } else if let viewModel = viewModel as? SectionCellVM {
            let cell = tableView.dequeueReusableCell(for: indexPath) as SectionsTableViewCell
            cell.viewModel = viewModel
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = cellsVM[safe: indexPath.row] else {
            return
        }

        if viewModel is CardCellVM {
            perform(segue: StoryboardSegue.Profile.bonuses)
        }
    }
}

extension ProfileViewController: ModalControllerDelegate {
    var closeButtonStyle: ModalController.CloseButtonStyle {
        .close
    }

    func modalControllerShouldClose(_: ModalController) -> Bool {
        dismissToRoot()
        return false
    }
}
