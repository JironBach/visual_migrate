require "test_helper"

class IndexControllerTest < ActionController::TestCase
  before do
    get :index
  end

	describe IndexController do
	  it '正常終了すること' do
	    response.status.must_equal 200
	  end

	  it "タイトルを含むこと" do
	    page.must_contain '<title>VisualMigrate</title>'
	  end

	  it "テーブルを含むこと" do
	    page.must_contain '<table'
	  end

	end
end
