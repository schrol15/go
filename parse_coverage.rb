require 'json'

files = {}
size = 0
covered = 0

data = File.read('coverage.txt')
data = data.split("\n")
data = data[1..data.size]
data = data.map { |line| line.split(':') }

data.each do |line|
  file = line.first
  coverage = line.last

  unless files[file]
    files[file] = {}
    files[file][:lines] = []
    files[file][:number_of_lines] = File.foreach("../#{file}").count
    size += files[file][:number_of_lines]
  end

  beggining, finish = coverage.split(' ').first.split(',').map { |e| e[0...e.index('.')].to_i }
  hits = coverage.split(' ').last.to_i
  if hits > 0
    covered += (beggining..finish).size
    files[file][:lines] += (beggining..finish).map do |line|
      { line.to_s => hits }
    end
  end
end

report = {}

report[:total] = (covered/size.to_f*100).to_i
report[:fileReports] = files.map do |file, values|
  {
    filename: file.split('/')[1..-1].join('/'),
    total: (values[:lines].size/values[:number_of_lines].to_f*100).to_i,
    coverage: files[file][:lines].reduce(Hash.new, :merge)
  }
end

puts report.to_json
