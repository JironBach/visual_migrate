# -*- coding:utf-8 -*-
require 'spec_helper'

describe 'index/index.html.erb' do
  before do
    visit '/index/index/'
  end

  it "著作権を表示すること" do
    expect(page).to.should have_content('Copyright &copy; 2013 VisualMigrate project.')
  end

  it "tableを表示しないこと" do
    expect(page).to.should_not have_tag('table')
  end

end
