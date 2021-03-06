# Construct an instance of the Active Record from a SQL result set row
# {"id"=>1, "name"=>"Steven", "super_power"=>"Time Travel", 0=>1, 1=>"Steven", 2=>"Time Travel"}


class Student # students
  @@db = SQLite3::Database.new('db/students_store.db')
  @@db.results_as_hash = true

  attr_accessor :id, :name, :super_power
  def self.new_from_row(row)
    s = new
    s.id = row["id"]
    s.name = row["name"]
    s.super_power = row["super_power"]
    s
  end

  def self.all
    sql = <<-SQL
    SELECT *
    FROM students
    SQL
    @@db.execute(sql).map do |row|
      new_from_row(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      -- WHERE name="#{name}"
      WHERE name= ?
    SQL

    @@db.execute(sql, [name]).map do |row|
      new_from_row(row)
    end.first
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

  def persisted?
    !!id
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name=?, super_power=?
      WHERE id=?
    SQL

    @@db.execute(sql, [name, super_power, id])
  end

  def insert
    sql = <<-SQL
    INSERT INTO students (name, super_power)
    VALUES (?,?)
    SQL

    @@db.execute(sql,[name, super_power])
    self.id = Student.all.last.id
  end
end
