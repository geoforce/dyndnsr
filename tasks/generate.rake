require 'fileutils'
namespace :generate do
  desc 'Generate a timestamped, empty Sequel migration. (For DDL)'
  task :migration, :name do |_, args|
    if args[:name].nil?
      puts 'You must specify a migration name (e.g. rake generate:migration[create_events])!'
      exit false
    end

    content = "Sequel.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\nend\n"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_directory = DynDnsR::MIGRATION_ROOT.to_s
    FileUtils.mkdir_p(migration_directory) unless File.directory?(migration_directory)
    filename = File.join(migration_directory, "#{timestamp}_#{args[:name]}.rb")

    File.open(filename, 'w') do |f|
      f.puts content
    end

    puts "Created the migration #{filename}"
  end

  desc 'Generate a timestamped, empty Sequel Seed file (for data CRUD)'
  task :seed, [:seed_path, :name] do |_, args|
    if args[:name].nil?
      puts 'You must specify a seed path and name (e.g. rake generate:seed[some_seed_path,systemroot_users])!'
      exit false
    end

    if args[:seed_path].nil?
      puts 'You must specify a seed path and name (e.g. rake generate:seed[key_energy,systemroot_users])!'
      exit false
    end

    content = "Sequel.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\nend\n"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_directory = DynDnsR::MIGRATION_ROOT.join('seeds', args[:seed_path])
    FileUtils.mkdir_p(migration_directory) unless File.directory?(migration_directory)
    filename = File.join(migration_directory, "#{timestamp}_#{args[:name]}.rb")

    File.open(filename, 'w') do |f|
      f.puts content
    end

    puts "Created the seed #{filename}"
  end
end
