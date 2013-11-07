# -*- coding:utf-8 -*-
require 'spec_helper'

describe IndexController do
	describe 'マイグレート前のindex#indexは、' do
	  before do
      get :index
	  end

	 	it "status 200であること" do
	    response.status.should be(200)
	  end

	 	it "index#indexを描画すること" do
	    response.should render_template("index")
	  end

	end
end
