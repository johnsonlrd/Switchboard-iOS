//
//  MainViewController.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import UIKit
import Switchboard

final class MainViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    // MARK: - Private View Properties

    fileprivate lazy var showButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Show Switchboard Debug", for: .normal)
        button.addTarget(self, action: #selector(showDebugVC), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var resetButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Reset Switchboard", for: .normal)
        button.addTarget(self, action: #selector(resetSwitchboard), for: .touchUpInside)
        return button
    }()

    fileprivate var switchboardDebugView: SwitchboardDebugView?

}

// MARK: - Private API

fileprivate extension MainViewController {

    // MARK: - View Setup

    func setupView() {
        title = "Switchboard Example"
        view.backgroundColor = .white

        showButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showButton)
        NSLayoutConstraint.activate([showButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                                     showButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                                     showButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44),
                                     showButton.heightAnchor.constraint(equalToConstant: 44)])

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        NSLayoutConstraint.activate([resetButton.leadingAnchor.constraint(equalTo: showButton.leadingAnchor),
                                     resetButton.trailingAnchor.constraint(equalTo: showButton.trailingAnchor),
                                     resetButton.topAnchor.constraint(equalTo: showButton.bottomAnchor),
                                     resetButton.heightAnchor.constraint(equalTo: showButton.heightAnchor)])
    }

    // MARK: - Actions

    @objc func showDebugVC() {
        switchboardDebugView = SwitchboardDebugView(switchboard: ExampleSwitchboard.shared)
        switchboardDebugView?.refreshHandler = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.confirmSwitchboardRefresh()
        }
        guard let debugView = switchboardDebugView else { return }
        navigationController?.pushViewController(debugView, animated: true)
    }

    @objc func resetSwitchboard() {
        SwitchboardDebugController(switchboard: ExampleSwitchboard.shared).clearCacheAndSwitchboard()
        ExampleSwitchboard.shared.activate(serverUrlString: ExampleSwitchboard.serverUrlString, completion: nil)
        print("Switchboard has been reset back to the 'server' values")
    }

    // MARK: - Refreshing

    func confirmSwitchboardRefresh() {
        let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm you want to clear Switchboard debugging and hard reset everything back to the server.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.switchboardDebugView?.clearCacheAndSwitchboard()
            ExampleSwitchboard.shared.activate(serverUrlString: ExampleSwitchboard.serverUrlString) { _ in
                self?.switchboardDebugView?.reload()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.switchboardDebugView?.reload()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}
