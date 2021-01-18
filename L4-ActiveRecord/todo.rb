require "active_record"

class Todo < ActiveRecord::Base
  def due_today?
    due_date == Date.today
  end

  def due_later?
    due_date > Date.today
  end

  def overdue?
    due_date < Date.today
  end

  def to_displayable_string
    display_status = completed ? "[X]" : "[ ]"
    display_date = due_today? ? nil : due_date
    "#{id}. #{display_status} #{todo_text.strip} #{display_date}"
  end

  def self.show_list
    puts "My Todo-list\n\n"

    puts "Overdue\n"
    overdue_todos = all.filter { |todo| todo.overdue? }
    puts overdue_todos.map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Today\n"
    due_today_todos = all.filter { |todo| todo.due_today? }
    puts due_today_todos.map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Later\n"
    due_later_todos = all.filter { |todo| todo.due_later? }
    puts due_later_todos.map { |todo| todo.to_displayable_string }
    puts "\n\n"
  end

  def self.add_task(task)
    create!(todo_text: task[:todo_text], due_date: Date.today + task[:due_in_days], completed: false)
  end

  def self.mark_as_complete!(id)
    todo = find(id)
    if (todo)
      todo.completed = true
      todo.save
      todo
    end
  end
end
