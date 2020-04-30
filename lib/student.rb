require_relative "../config/environment.rb"

class Student
attr_accessor :name, :grade, :id
  #This method takes in three arguments, the id, name and grade. The id should default to nil.
  def initialize (id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  #This class method creates the students table with columns that match the attributes of our individual students: an id (which is the primary key), the name and the grade.
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  #This class method should be responsible for dropping the students table.
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  #This instance method inserts a new row into the database using the attributes of the given object. This method also assigns the id attribute of the object once the row has been inserted into the database
  def save
    if self.id
      self.update
    
    else
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  #This method creates a student with two attributes, name and grade, and saves it into the students table.
  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  #This class method takes an argument of an array. When we call this method we will pass it the array that is the row returned from the database by the execution of a SQL query. We can anticipate that this array will contain three elements in this order: the id, name and grade of a student.
  def self.new_from_db(row)
   new_student = Student.new("tempname", 0)
   new_student.id = row[0]
   new_student.name = row[1]
   new_student.grade = row[2]
    new_student

  end

  #This class method takes in an argument of a name. It queries the database table for a record that has a name of the name passed in as an argument. Then it uses the #new_from_db method to instantiate a Student object with the database row that the SQL query returns.
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  #This method updates the database row mapped to the given Student instance.
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



end
