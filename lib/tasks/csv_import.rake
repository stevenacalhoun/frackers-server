require 'csv'
require 'aws-sdk'

namespace :csv_import do
  task all: :environment do
    Rake::Task["csv_import:well_data"].invoke
    Rake::Task["csv_import:well_purpose"].invoke
    Rake::Task["csv_import:well_ingredients"].invoke
    Rake::Task["csv_import:pollution_data"].invoke
  end

  task aws_well_data: :environment do
    s3 = Aws::S3::Resource.new(
      region: 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    data = s3.bucket('frackers-data').object('WellData.csv').get
    csvData = CSV.parse(data.body, :headers => false)
    csvData.each do |row|
      WellEntry.create(id: row[0], owner: row[1], latitude: row[2], longitude: row[3], state: row[4], city: row[5])
    end
  end

  task :aws_pollution_entry, [:file_section] => :environment do |t, args|
    s3 = Aws::S3::Resource.new(
      region: 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    data = s3.bucket('frackers-data').object('PollutionData-'+args[:file_section]+'.csv').get

    @i = 0
    @count = 0
    data.body.each do |line|
      begin
        @count += 1
        line = line.gsub("\u0000", '')
        CSV.parse(line) do |row|
          PollutionEntry.create(latitude: row[4], longitude: row[5], country_code: row[6], state_code: row[7], project_id: row[11], location_id: row[12], characteristic_name: row[13], start_date: row[9], end_date: row[10], value: row[14], unit_code: row[15])
        end
      rescue => e
        @i = @i + 1
        puts e
        puts "Bad Pollution Line: " + @count.to_s + "(" + @i.to_s + ")"
      end
    end
  end

  task well_data: :environment do
    csv_text = File.read('data/WellData.csv')
    csv = CSV.parse(csv_text, :headers => false)
    csv.each do |row|
      WellEntry.create(id: row[0], owner: row[1], latitude: row[2], longitude: row[3], state: row[4], city: row[5])
    end
  end

  task well_purpose: :environment do
    @i = 0
    @count = 0
    File.foreach('data/WellPurpose.csv') do |line|
      @count += 1
      begin
        @count += 1
        line = line.gsub("\u0000", '')
        CSV.parse(line) do |row|
          WellPurpose.create(purpose_key: row[0], well_key: row[1], purpose: row[4], trade_name: row[2])
        end
      rescue => e
        @i = @i + 1
        puts e
        puts "Bad Purpose Line: " + @count.to_s + "(" + @i.to_s + ")"
      end
    end
  end

  task well_ingredients: :environment do
    @i = 0
    @count = 0
    File.foreach('data/WellIngredients.csv') do |line|
      begin
        @count += 1
        line = line.gsub("\u0000", '')
        CSV.parse(line) do |row|
          WellIngredient.create(ingredient_key: row[0], purpose_key: row[1], ingredient_name: row[2], percent_high_additive: row[4], percent_mass: row[5])
        end
      rescue => e
        @i = @i + 1
        puts e
        puts "Bad Ingredient Line: " + @count.to_s + "(" + @i.to_s + ")"
      end
    end
  end

  task pollution_data: :environment do
    @i = 0
    @count = 0
    File.foreach('data/PollutionData.csv') do |line|
      begin
        @count += 1
        line = line.gsub("\u0000", '')
        CSV.parse(line) do |row|
          PollutionEntry.create(latitude: row[4], longitude: row[5], country_code: row[6], state_code: row[7], project_id: row[11], location_id: row[12], characteristic_name: row[13], start_date: row[9], end_date: row[10], value: row[14], unit_code: row[15])
        end
      rescue => e
        @i = @i + 1
        puts e
        puts "Bad Pollution Line: " + @count.to_s + "(" + @i.to_s + ")"
      end
    end
  end
end
