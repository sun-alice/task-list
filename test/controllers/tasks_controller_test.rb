require "test_helper"

describe TasksController do
  let (:task) {Task.create name: "sample task", description: "this is an example for a test",
  completion_date: Time.now + 5.days}
  
  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get tasks_path
      
      # Assert
      must_respond_with :success
    end
    
    it "can get the root path" do
      # Act
      get root_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  # Unskip these tests for Wave 2
  describe "show" do
    it "can get a valid task" do
      # Act
      get task_path(task.id)
      
      # Assert
      must_respond_with :success
    end
    
    it "will redirect for an invalid task" do
      # Act
      get task_path(-1)
      
      # Assert
      must_respond_with :redirect
    end
  end
  
  describe "new" do
    it "can get the new task page" do
      # Act
      get new_task_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  describe "create" do
    it "can create a new task" do
      # Arrange
      task_hash = {task: {name: "new task", description: "new task description", completion_date: nil }}
      
      # Act-Assert
      expect {post tasks_path, params: task_hash}.must_change "Task.count", 1
      
      new_task = Task.find_by(name: task_hash[:task][:name])
      expect(new_task.description).must_equal task_hash[:task][:description]
      expect(new_task.completion_date).must_equal task_hash[:task][:completion_date]
      
      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end
  
  # Unskip and complete these tests for Wave 3
  describe "edit" do
    it "can get the edit page for an existing task" do
      get edit_task_path(task.id)
      
      must_respond_with :success
    end
    
    it "will respond with redirect when attempting to edit a nonexistant task" do
      get edit_task_path(9999)
      
      must_respond_with :redirect
      must_redirect_to root_path
    end
    
  end
  
  describe "update" do
    # Note:  If there was a way to fail to save the changes to a task, that would be a great
    #        thing to test.
    before do
      @test_task_id = task.id
      @task_hash = {task: {name: "changed task name", description: "changed description", completion_date: nil}}
    end
    
    it "can update an existing task" do
      expect {patch task_path(@test_task_id), params: @task_hash}.wont_change "Task.count"
      
      new_task = Task.find_by(name: @task_hash[:task][:name])
      expect(new_task.name).must_equal @task_hash[:task][:name]
      expect(new_task.description).must_equal @task_hash[:task][:description]
      expect(new_task.completion_date).must_equal @task_hash[:task][:completion_date]
      
      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
    
    it "will redirect to the root page if given an invalid id" do
      patch task_path(9999), params: @task_hash
      
      must_respond_with :redirect
      must_redirect_to root_path
    end
    
    it "wont update if params are invalid" do
      unchanged_task = Task.find_by(id: @test_task_id)
      
      expect {patch task_path(@test_task_id), params: {}}.must_raise
      
      updated_task = Task.find_by(id: @test_task_id)
      expect(updated_task.name).must_equal unchanged_task.name
      expect(updated_task.description).must_equal unchanged_task.description
      expect(updated_task.completion_date).must_equal unchanged_task.completion_date
    end
  end
  
  # Complete these tests for Wave 4
  describe "destroy" do
    it "can delete a task" do
      test_task_id = Task.create(name: "test")
      new_task = Task.find_by(id: test_task_id)
      
      expect {delete task_path(new_task.id) }.must_differ 'Task.count', -1
      
      must_respond_with :redirect
      must_redirect_to tasks_path
    end
    
    it "will redirect for an invalid task" do
      expect {delete task_path(9999) }.wont_change 'Task.count'
      
      must_respond_with :redirect
      must_redirect_to tasks_path
    end
  end
  
  # Complete for Wave 4
  describe "complete" do
    before do
      @test_task_id = Task.create(name: "test")
      @new_task = Task.find_by(id: @test_task_id)
    end
    
    it "will mark a task as complete if it is currently nil" do
      expect{patch complete_task_path(@new_task.id)}.wont_change "Task.count"
      test_task = Task.find_by(id: @test_task_id)
      
      expect(test_task.completion_date.class).wont_be_nil
      expect(test_task.name).must_equal @new_task.name
      expect(test_task.description).must_equal @new_task.description
      
      must_respond_with :redirect
      must_redirect_to tasks_path
    end
    
    it "will mark a task as nil if it is currently complete" do
      expect{patch complete_task_path(@new_task.id)}.wont_change "Task.count"
      test_task = Task.find_by(id: @test_task_id)
      
      expect(@new_task.completion_date).must_equal nil
      expect(test_task.name).must_equal @new_task.name
      expect(test_task.description).must_equal @new_task.description
      
      must_respond_with :redirect
      must_redirect_to tasks_path
    end
    
    it "will redirect to the task page if given an invalid id" do
      expect{patch complete_task_path(999)}.wont_change "Task.count"
      
      must_respond_with :redirect
      must_redirect_to tasks_path
    end
  end
end

