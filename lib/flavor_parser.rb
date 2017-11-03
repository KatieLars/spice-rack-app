class FlavorParser

  def self.call
    self.new.class_builder(file)
  end

  def file #reads file data, spits out an array
    File.read("./db/data/data.db").gsub("\n", "").split(",")
  end

  def class_builder(file) #builds classes
    file.collect {|flavor| Flavor.find_or_create_by(name: flavor)}
  end

end
