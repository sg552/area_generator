class Interface::AreasController < Interface::ApplicationController

  def area_data
    render json: Province.order('id asc').all.map { |province|
      {
        name: province.name,
        cityList: province.cities.map { |city|
          {
            name: city.name,
            cityList: city.towns.blank?  ?
            [
              {
                name: ""
              }
            ] :
            city.towns.map { |town|
              {
                name: town.name
              }
            }
          }
        }
      }
    }
  end
end
