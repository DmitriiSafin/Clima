//
//  WeatherViewController.swift
//  Clima
//
//  Created by Дмитрий on 15.02.2023.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    private lazy var bacgroundImageView: UIImageView = {
        let image = UIImage(named: "background")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.contentMode = .scaleToFill
        return stack
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(getWeather), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 25)
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .clear
        textField.placeholder = "Search"
        textField.autocapitalizationType = .words
        textField.returnKeyType = .go
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let image = UIImage(systemName: "sun.max")
        let view = UIImageView(image: image)
        view.tintColor = .label
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        view.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    private lazy var temperatureStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.contentMode = .scaleToFill
        return stack
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "21"
        label.font = .systemFont(ofSize: 80, weight: .heavy)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var degreeLabel: UILabel = {
        let label = UILabel()
        label.text = "°"
        label.font = .systemFont(ofSize: 100)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var cLabel: UILabel = {
        let label = UILabel()
        label.text = "C"
        label.font = .systemFont(ofSize: 100)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = "London"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var constrView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .trailing
        stack.contentMode = .scaleToFill
        return stack
    }()
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         setupConstraints()
    }
    
    @objc func getWeather() {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    @objc func searchPressed() {
        searchTextField.endEditing(true)
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - Constraints
extension WeatherViewController {
    
    func setupConstraints() {
        
        let views = [bacgroundImageView, locationButton, searchTextField, searchButton, temperatureLabel, degreeLabel, cLabel, searchStackView, conditionImageView, temperatureStackView, cityLabel, constrView, mainStackView]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(bacgroundImageView)
        searchStackView.addArrangedSubview(locationButton)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(searchButton)
        
        temperatureStackView.addArrangedSubview(temperatureLabel)
        temperatureStackView.addArrangedSubview(degreeLabel)
        temperatureStackView.addArrangedSubview(cLabel)
        
        mainStackView.addArrangedSubview(searchStackView)
        mainStackView.addArrangedSubview(conditionImageView)
        mainStackView.addArrangedSubview(temperatureStackView)
        mainStackView.addArrangedSubview(cityLabel)
        mainStackView.addArrangedSubview(constrView)
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            bacgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bacgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bacgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bacgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            searchStackView.leftAnchor.constraint(equalTo: mainStackView.leftAnchor),
            searchStackView.rightAnchor.constraint(equalTo: mainStackView.rightAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
    }
}
