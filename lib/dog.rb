require 'pry'
class Dog
    attr_accessor :name, :breed, :id
    @@dogs = []
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
        @@dogs << self
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end
    
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def self.new_from_db(array)
          self.new(id: array[0], name: array[1], breed: array[2])
         

    end 
   
    def self.find_by_name(name)
        
        sql = <<-SQL
            SELECT * FROM dogs where name = ?;
        SQL

        result = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(result)
    end 



    def save
        if self.id 
            self.update
        else 
            sql = <<-SQL
                INSERT INTO dogs(name, breed) VALUES (?, ?);
            SQL
            
            result = DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            
        end
        self
    end 

    def self.create(hash)
        new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
        new_dog.save
    end 

    def self.all
        @@dogs
    end 

    def self.find_by_id(id)
        Dog.all.find do |dog|
            dog.id ==  id
        end 
    end 

    def self.find_or_create_by(name:, breed:)
        
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            new_dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
        else
           new_dog = Dog.create(name: name, breed: breed)
        end 

        new_dog
    end 

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL
        result = DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end 