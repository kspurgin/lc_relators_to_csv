module LcRelatorsToCsv
  class Terms
    def initialize(terms)
      @all = terms
    end

    def active
      @all.reject{ |term| term.deprecated? }
    end
    
    def deprecated
      @all.select{ |term| term.deprecated? }
    end

    def write_active(path)
      CSV.open(File.expand_path(path), 'wb') do |csv|
        csv << headers
        active.each do |term|
          csv << ["role_#{term.code}", term.csv_row].flatten
        end
      end
    end

    def write_deprecated(path)
      CSV.open(File.expand_path(path), 'wb') do |csv|
        csv << deprecated_headers
        deprecated.each do |term|
          csv << ["role_#{term.code}", term.csv_row].flatten
        end
      end
    end

    private

    def headers
      %w[id name description uri code alt_names collection vocabulary]
    end

    def deprecated_headers
      dep_hdr = headers.dup
      dep_hdr << %w[deprecated superseded_by]
      dep_hdr.flatten
    end
  end
end
