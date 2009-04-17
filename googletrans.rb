require 'rubygems'
require 'open-uri'
require 'json'
require 'uri'

class GoogleTranslateException < RuntimeError
end

class GoogleTranslator
  GOOGLE_TRANSLATION_API_REST_URL = "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=@query&langpair=@lang_from%7C@lang_to"
  
  def initialize(lang_from, lang_to)
    @lang_from = lang_from
    @lang_to = lang_to
  end
  
  def translate(query_text)
    translated_text = ''
    begin
      open(build_query(query_text)) do |pipe|
          response = JSON.parse(pipe.read)
          if response['responseStatus'] == 200
            translated_text = response['responseData']['translatedText']
          else
            raise GoogleTranslateException, 'ERROR '+response['responseStatus'].to_s+' '+response['responseDetails']
          end
      end
    rescue Exception => e
      raise GoogleTranslateException, "Error occurred: #{e.message}"+(ENV['DEBUG'] ? "\n"+e.backtrace.join("\n") : '' )
    end
    return translated_text
  end
  
  private
  
  def build_query(query_text)
    GOOGLE_TRANSLATION_API_REST_URL.gsub(/@query|@lang_from|@lang_to/) do |match|
      case match
        when '@query'     : URI.escape(query_text)
        when '@lang_from' : @lang_from
        when '@lang_to'   : @lang_to
      end
    end
  end
end


