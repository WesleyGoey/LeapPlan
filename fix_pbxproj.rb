require 'xcodeproj'
project_path = 'LeapPlan.xcodeproj'
project = Xcodeproj::Project.open(project_path)

watch_target = project.targets.find { |t| t.name == 'Leaplan_Watch Watch App' }
if watch_target
  # 1. Remove FirebaseFirestore, FirebaseAnalytics, FirebaseAppCheck, FirebaseDatabase from Frameworks
  frameworks_phase = watch_target.frameworks_build_phase
  frameworks_phase.files.each do |file|
    if file.display_name && file.display_name.include?('Firebase') && file.display_name != 'FirebaseCore.framework' && file.display_name != 'FirebaseAuth.framework'
      puts "Removing #{file.display_name} from Watch target frameworks"
      file.remove_from_project
    end
  end

  # 2. Add models to target membership Exceptions for PBXFileSystemSynchronizedRootGroup
  # Actually, Xcodeproj might not fully support PBXFileSystemSynchronizedBuildFileExceptionSet easily if it's very new (Xcode 16).
  # Instead of PBXFileSystemSynchronizedRootGroup, I can just add them manually to PBXSourcesBuildPhase, which always works.
  
  sources_phase = watch_target.source_build_phase
  
  files_to_add = [
    'LeapPlan/Models/Trip.swift',
    'LeapPlan/Enums/TripStatus.swift',
    'LeapPlan/Models/TripDestination.swift',
    'LeapPlan/Models/DayPlan.swift',
    'LeapPlan/Models/User.swift',
    'Leaplan_Watch Watch App/Managers/WatchSessionManager.swift',
    'Leaplan_Watch Watch App/Viewmodel/WatchAppViewModel.swift'
  ]
  
  files_to_add.each do |path|
    file_ref = project.files.find { |f| f.path == path || (f.real_path && f.real_path.to_s.end_with?(path)) }
    if file_ref
      unless sources_phase.files.any? { |f| f.file_ref == file_ref }
        puts "Adding #{path} to Watch target sources"
        sources_phase.add_file_reference(file_ref)
      end
    else
      # If not found directly, create a reference
      # (This might be tricky with synchronized groups, but worth a try)
      puts "Warning: Could not find #{path} in project.files"
    end
  end
end

project.save
