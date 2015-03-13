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

Rails.application.configure do
  if MailerSettings.exception_notification.notify_errors
    config.middleware.use ExceptionNotification::Rack, {
      email: {
        email_prefix: "[EDO-pc Exception] ",
        sender_address: MailerSettings.exception_notification.sender_address,
        exception_recipients: MailerSettings.exception_notification.exception_recipients
      }
    }
  end
end