require 'spec_helper'

describe FacebookApp do
  before do
    str = 'access_token=AAAC3m6xhWLwBACP5bLqeEndWnZASoAZBexiKNJT7VTEw2uewaTSlcdkZAUfmengE63u4SLl1uDKB5WvnO7IGVZAYxXWFoj26UooLL4tQRAZDZD&base_domain=pair.dev&expires=1315101600&secret=P6U2bOTBY4Lb7GJQeZFuHg__&session_key=2.AQCcgWeat9laiBhw.3600.1315101600.1-37901410&sig=6bd85f8cfc19c51aab2fa33ec016d5e3&uid=37901410'
    @session = URL::ParamsHash.from_string str
    @fbapp = FacebookApp.dev
  end

  it "should validate" do
    @fbapp.valid_params?(@session).should be true
  end
end