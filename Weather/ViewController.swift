//
//  ViewController.swift
//  Weather
//
//  Created by 문성진 on 2022/11/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var weatherDescriptionLable: UILabel!
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var minTempLable: UILabel!
    @IBOutlet weak var maxTempLable: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLable.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLable.text = weather.description
        }
        self.tempLable.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLable.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.maxTempLable.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))°C"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=40247f98cff49ef5b3ac1567ef6dc6ab") else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
           
        }.resume()
    }
}


