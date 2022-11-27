require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

attr_accessor :name, :grade, :id

  def initialize id = nil, name, grade
    @id = id
    @name = name
    @grade =grade    
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?,?)
    SQL

    if self.id
      self.update
    else
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create name, grade
    self.create_table
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db (row)
    self.new(row[0],row[1],row[2])
  end

  def self.find_by_name find_name
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    row = DB[:conn].execute(sql,find_name)[0]
    self.new_from_db(row)

  end

end
