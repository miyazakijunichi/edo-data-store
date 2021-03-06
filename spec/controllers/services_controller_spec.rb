#--
# Copyright 2015 realglobe, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++

require 'rails_helper'

RSpec.describe ServicesController, :type => :controller do
  before :all do
    user = StoreAgent::User.new("user_001")
    user.workspace("user_001").create
  end
  before do
    request.headers["Content-Type"] = "application/json"
  end
  let :user_uid do
    "user_001"
  end

  context "GET /users/xxx/services" do
    let :user_uid do
      "user_002"
    end
    before do
      user = StoreAgent::User.new(user_uid)
      workspace = user.workspace(user_uid)
      if workspace.exists?
        workspace.delete
      end
      workspace.create
    end
    it "登録されているユーザーのUID一覧を返す" do
      user = StoreAgent::User.new(user_uid)
      workspace = user.workspace(user_uid)
      service_identifiers = %w(service_001 service_002 service_foo service_bar)
      service_identifiers.each do |uid|
        workspace.directory(uid).create
      end
      get :index, {user_uid: user_uid}
      expect(Oj.load(response.body).sort).to eq service_identifiers.sort
    end
    it "サービスが登録されていない場合、services は空配列" do
      get :index, {user_uid: user_uid}
      expect(Oj.load(response.body)).to eq []
    end
  end

  context "POST /users/xxx/services" do
    it "Content-Type が application/json でないと 400 エラーを返す" do
      request.headers["Content-Type"] = "text/html"
      post :create, {user_uid: user_uid, service_uid: :service_001}
      expect(response.status).to eq 400
    end
    it "service_uid パラメータが無いと 500 エラーを返す" do
      pending

      post :create, {user_uid: user_uid}
      expect(response.status).to eq 500
    end
    it "user_uid、service_uid パラメータが正しければサービス登録され、201 を返す" do
      post :create, {user_uid: user_uid, service_uid: :service_001}
      expect_201_created(data: {uid: "service_001"})
    end
    it "service_uid が重複したら 409 エラーを返す" do
      post :create, {user_uid: user_uid, service_uid: :service_002}
      post :create, {user_uid: user_uid, service_uid: :service_002}
      expect_409_error(error_message: "service already exists")
    end
  end

  context "DELETE /users/xxx/services/yyy" do
    let :user_uid do
      "user_del"
    end
    before :all do
      user_uid = "user_del"
      user = StoreAgent::User.new(user_uid)
      workspace = user.workspace(user_uid)
      workspace.create
    end
    it "サービスが削除され、204 を返す" do
      service_uid = "service_del"
      user = StoreAgent::User.new(user_uid)
      workspace = user.workspace(user_uid)
      workspace.directory(service_uid).create
      delete :destroy, {user_uid: user_uid, service_uid: service_uid}
      expect(response.status).to eq 204
      expect(workspace.directory(workspace).exists?).to be false
    end
    it "サービスが存在しない場合、404 エラーを返す" do
      delete :destroy, {user_uid: user_uid, service_uid: "dummy_service"}
      expect_404_error(error_message: "service not found")
    end
  end
end
