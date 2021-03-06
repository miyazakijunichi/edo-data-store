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

RSpec.describe UsersController, :type => :controller do
  before do
    request.headers["Content-Type"] = "application/json"
  end

  context "GET /users" do
    before do
      if File.exists?(StoreAgent.config.storage_root)
        FileUtils.remove_dir(StoreAgent.config.storage_root)
      end
      FileUtils.mkdir(StoreAgent.config.storage_root)
    end
    it "登録されているユーザーのUID一覧を返す" do
      user_identifiers = %w(user_001 user_002 user_foo user_bar)
      user_identifiers.each do |uid|
        user = StoreAgent::User.new(uid)
        workspace = user.workspace(uid)
        workspace.create
      end
      get :index
      expect(Oj.load(response.body).sort).to eq user_identifiers.sort
    end
    it "ユーザーが登録されていない場合、users は空配列" do
      get :index
      expect(Oj.load(response.body)).to eq []
    end
  end

  context "POST /users" do
    it "Content-Type が application/json でないと 400 エラーを返す" do
      request.headers["Content-Type"] = "text/html"
      post :create, {user_uid: :foobar}
      expect(response.status).to eq 400
    end
    it "user_uid パラメータが無いと 500 エラーを返す" do
      pending

      post :create, {}
      expect(response.status).to eq 500
    end
    it "user_uid が正しければユーザーが作成され、201 を返す" do
      post :create, {user_uid: :hoge}
      expect_201_created(data: {uid: :hoge})
    end
    it "user_uid が重複したら 409 エラーを返す" do
      post :create, {user_uid: :fuga}
      post :create, {user_uid: :fuga}
      expect_409_error(error_message: "user already exists")
    end
  end

  context "DELETE /users/xxx" do
    it "ユーザーが削除され、204 を返す" do
      uid = "user_del"
      user = StoreAgent::User.new(uid)
      workspace = user.workspace(uid)
      workspace.create
      delete :destroy, {user_uid: uid}
      expect(response.status).to eq 204
      expect(File.exists?("#{StoreAgent.config.storage_root}/#{uid}")).to be false
    end
    it "ユーザーが存在しない場合、404 エラーを返す" do
      delete :destroy, {user_uid: "dummy_user"}
      expect_404_error(error_message: "user not found")
    end
  end
end
