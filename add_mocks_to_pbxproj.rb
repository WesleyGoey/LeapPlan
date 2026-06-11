require 'xcodeproj'

project_path = 'LeapPlan.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the test target
test_target = project.targets.find { |t| t.name == 'LeapPlanTests' }

# Find or create groups
tests_group = project.main_group.find_subpath('LeapPlanTests', true)
mocks_group = tests_group.find_subpath('Mocks', true)
repos_group = mocks_group.find_subpath('Repositories', true)
services_group = mocks_group.find_subpath('Services', true)

repo_file_path = 'LeapPlanTests/Mocks/Repositories/MockGroqRepository.swift'
service_file_path = 'LeapPlanTests/Mocks/Services/MockGroqService.swift'

# Add repo file
if !repos_group.files.find { |f| f.path == repo_file_path.split('/').last }
  file_ref = repos_group.new_reference(repo_file_path)
  test_target.source_build_phase.add_file_reference(file_ref)
  puts "Added MockGroqRepository"
end

# Add service file
if !services_group.files.find { |f| f.path == service_file_path.split('/').last }
  file_ref = services_group.new_reference(service_file_path)
  test_target.source_build_phase.add_file_reference(file_ref)
  puts "Added MockGroqService"
end

project.save
puts "Saved pbxproj"
