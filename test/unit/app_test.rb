require 'test_helper'

class AppTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end




# == Schema Information
#
# Table name: apps
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  nicename      :string(255)
#  url           :string(255)
#  app_key       :string(255)
#  app_token     :string(255)
#  ip            :string(15)
#  description   :text
#  members_count :integer(4)      default(0), not null
#  kandies_count :integer(4)      default(0), not null
#  status        :integer(2)      default(1), not null
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_apps_on_name       (name) UNIQUE
#  index_apps_on_nicename   (nicename) UNIQUE
#  index_apps_on_url        (url) UNIQUE
#  index_apps_on_app_key    (app_key) UNIQUE
#  index_apps_on_app_token  (app_token) UNIQUE
#  index_apps_on_ip         (ip) UNIQUE
#

