xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!

xml.OneBoxResults "xmlns:xlink" => "http://www.w3.org/1999/xlink" do
  xml.resultCode "success"
  xml.totalResults @results.length
  xml.urlText t("txt.views.similar_terms.title")
  xml.urlLink url_for(request.query_parameters.
      merge(:only_path => false, :anchor => ""))
  xml.MODULE_RESULT do
    xml.title t("txt.views.similar_terms.results_heading",
        :terms => params[:terms])
    @results.each do |label|
      xml.Field label.value, "name" => label.value
    end
  end if @results.length > 0
end
