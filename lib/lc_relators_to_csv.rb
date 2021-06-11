require "lc_relators_to_csv/version"

require 'csv'

require 'pry'

require 'rdf'
require 'rdf/ntriples'

module LcRelatorsToCsv
  class Error < StandardError; end

  Dir[File.dirname(__FILE__) + '/../lib/lc_relators_to_csv/*.rb'].each do |file|
    require "lc_relators_to_csv/#{File.basename(file, File.extname(file))}"
  end

  graph = LcRelatorsToCsv::RelatorGraph.new('~/data/lc_relators/vocabularyrelators.nt')
  terms = LcRelatorsToCsv::Terms.new(graph.terms)

  active = '~/code/islandora8-ecs/docker/lyrasis-drupal/drupal/web/modules/custom/lyrasis_module/migrate/agent_roles.csv'
  deprecated = '~/code/islandora8-ecs/docker/lyrasis-drupal/drupal/web/modules/custom/lyrasis_module/migrate/agent_roles_deprecated.csv'

  terms.write_active(active)
  terms.write_deprecated(deprecated)
end
