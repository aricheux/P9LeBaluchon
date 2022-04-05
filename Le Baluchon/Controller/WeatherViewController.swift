//
//  WeatherViewController.swift
//  Le Baluchon
//
//  Created by Yoan on 15/03/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    var locationManager = CLLocationManager()
    var newYorkCity = "New York"
    var arrayDataWeather: [WeatherJson] = []

    @IBOutlet weak var uiViewButton: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var weatherTableView: UITableView!

    // MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayDataWeather = []
        callWeatherServices(city: newYorkCity)
        uiViewButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weatherTableView.reloadData()
    }

    // MARK: - @IBAction
    @IBAction func dissmissKeyboard(_ sender: UITapGestureRecognizer) {
        uiViewButton.isHidden = true
        cityTextField.resignFirstResponder()
    }

    @IBAction func userLocalisationActionButton(_ sender: UIButton) {
        cityTextField.resignFirstResponder()
        uiViewButton.isHidden = true
        userLocationRequest()
    }

    // MARK: - private functions

    private func callWeatherServices(city: String) {
        WeatherServices.shared.getWeatherJson(city: city) { result in

            switch result {
            case .success(let myWeather):
                self.arrayDataWeather.append(myWeather)
                self.weatherTableView.reloadData()
            case .failure(let error):
                self.presentAlert(alertMessage: error.localizedDescription)
            }
        }
    }

    private func presentAlert (alertTitle title: String = "Error", alertMessage message: String,
                               buttonTitle titleButton: String = "Ok",
                               alertStyle style: UIAlertAction.Style = .cancel ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }

}

// MARK: - Extension location Manager Delegate

extension WeatherViewController: CLLocationManagerDelegate {
    private func userLocationRequest() {
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first else {
                return
            }
            guard let cityName = firstPlace.locality else {
                return
            }
            self.callWeatherServices(city: cityName)
            self.locationManager.stopUpdatingLocation()
        }
    }
}

// MARK: - Extension UItexteField delegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let city = cityTextField.text else {
            cityTextField.resignFirstResponder()
            return true
        }
        cityTextField.resignFirstResponder()
        uiViewButton.isHidden = true
        callWeatherServices(city: city)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        uiViewButton.isHidden = false
    }
}

// MARK: - tableView DataSource

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataWeather.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherData = arrayDataWeather[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
                as? WeatherTableViewCell else {
                    return UITableViewCell()
                }
        cell.configureCellWeather(city: weatherData.name, temp: weatherData.main?.temp,
                                  tempMin: weatherData.main?.temp_min, tempMax: weatherData.main?.temp_max,
                                  sunrise: weatherData.sys?.sunrise, sunset: weatherData.sys?.sunset,
                                  weatherIcon: weatherData.weather.first??.icon,
                                  description: weatherData.weather.first??.description)

        return cell
    }
}
