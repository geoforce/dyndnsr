namespace :db do
  task :connect do
    require_relative '../lib/dyn_dns_r'
    DynDnsR::R 'db/init'
    Sequel.extension :migration
  end

  desc 'Print current schema version'
  task version: :connect do
    begin
      version = format('%s - %s', DynDnsR.db[:schema_migrations]
        .order(Sequel.desc(:filename)).first[:filename].sub(/\.rb$/, '')
        .split('_', 2))
    rescue
      0
    end
    puts "Schema Version: #{version}"
  end

  desc 'Clear data in all tables'
  task wipe: [:'db:connect'] do
    unless V2.options[:env] == 'test'
      fail 'You should probably not be wiping data here, Buddy'
    end
    beast_tables = V2.db.tables.reject do |n|
      n.to_s =~ /^(spatial_ref_sys|geo(metry|ography)_columns)$/
    end
    if beast_tables.size > 0
      V2.db.drop_table(*beast_tables, cascade: true)
      unless DB.fetch("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'etl'").first.nil? # rubocop:disable Metrics/LineLength
        V2.db.execute 'DROP SCHEMA etl CASCADE'
      end
      unless DB.fetch("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'gfv2'").first.nil? # rubocop:disable Metrics/LineLength
        V2.db.execute 'DROP SCHEMA gfv2 CASCADE'
      end
    end
  end

  namespace :migrate do

    desc 'Perform migration reset (full erase and migration up).'
    task reset: [:'db:connect'] do
      Rake::Task['db:wipe'].execute
      Rake::Task['db:migrate'].execute
      puts '*** db:migrate:reset completed ***'
      Rake::Task['db:version'].execute
    end

    desc 'Perform migration up/down to VERSION.'
    task :to, [:target] => [:'db:connect'] do |_, args|
      Rake::Task['db:version'].execute
      target = args.with_defaults(target: 0)[:target].to_i
      if target == 0
        puts ':target must be larger than 0. Use rake db:migrate:down to erase all data.' # rubocop:disable Metrics/LineLength
        exit false
      end

      Sequel::Migrator.run(DynDnsR.db, DynDnsR::MIGRATION_ROOT, target: target)
      puts "*** db:migrate:to VERSION=[#{target}] executed ***"
      Rake::Task['db:version'].execute
    end

    desc 'Perform migration up to latest migration available.'
    task up: [:'db:connect'] do
      Rake::Task['db:version'].execute
      Sequel::Migrator.run(DynDnsR.db, DynDnsR::MIGRATION_ROOT)
      puts '*** db:migrate:up executed ***'
      Rake::Task['db:version'].execute
    end

    desc 'Perform migration down (erase all data).'
    task down: [:'db:connect'] do
      Rake::Task['db:version'].execute
      Sequel::Migrator.run(DynDnsR.db, DynDnsR::MIGRATION_ROOT, target: 0)
      puts '*** db:migrate:down executed ***'
      Rake::Task['db:version'].execute
    end

  end

  desc 'Migrate to latest schema'
  task migrate: :connect do
    Rake::Task['db:migrate:up'].execute
  end
end
