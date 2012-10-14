require "carrot2/version"
require "builder"
require "rest-client"
require "json"

class Carrot2

  def initialize(endpoint = "http://localhost:8080/dcs/rest")
    @endpoint = endpoint
  end

  def cluster(documents, user_params = {})
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.searchresult do |s|
      documents.each do |document|
        s.document do |d|
          d.title document
        end
      end
    end

    default_params = {
      "dcs.output.format" => "JSON",
      "dcs.clusters.only" => true,
      "dcs.c2stream" => xml.target!,
      "MultilingualClustering.defaultLanguage" => "ENGLISH",
      :multipart => true
    }
    response = RestClient.post(@endpoint, user_params.merge(default_params)){|response, request, result| response }
    if response.code == 200
      JSON.parse(response.body)
    else
      raise "Bad response code from Carrot2 server: #{response.code}"
    end
  end

end
