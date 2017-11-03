class FlavorParser

  def class_builder(flavor_list)
    flavor_list.each {|flavor| flavor = Flavor.find_or_create_by(name: flavor)}
  end
  
end
