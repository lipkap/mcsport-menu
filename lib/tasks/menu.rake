#encoding: utf-8
require('open-uri')
require('nokogiri')
require('csv')

namespace :mcsport do

  desc "rake mcsport:import[http://www.url.do.pliku.xml,nazwa_pliku_wynikowego.csv]"
  task :import, [:url,:file] do |t, args|
    url = args[:url]
    file = args[:file] || "./output.csv"
    if url.nil?
      puts "Usage: rake mcsport:import[<URL>,[<plik_wynikowy.csv>]]"
      exit 1
    end
    puts "converting: #{url} to: #{file}"
    xml = Nokogiri::XML(open(url))
    header = %w(kod_towaru ean cena_detal_brutto nazwa nazwa_html opis_html)
    errs = {}
    CSV.open(file, 'w') do |csv|
      # header
      csv << ['producent'].concat(header)
      # miesko
      idx = 0
      cnt = xml.root.children.length
      xml.root.children.each_with_index do |row, idx|
        idx = idx + 1
        puts "processing #{idx}/#{cnt}"
        begin
          attribs = [xml.root.name]

          header.inject(attribs) do |memo, attrib|
            a = row.attributes[attrib]
            memo << a
            memo
          end
          csv << attribs
        rescue => e
          errs[idx.to_s.to_sym] = e.message
        end
      end

    end

    if errs.keys.length > 0
        puts "There were errors:"
        errs.each do |k,v|
          puts "Line #{k}: #{v}"
        end
    end
  end

end
