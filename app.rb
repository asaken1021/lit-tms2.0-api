require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require 'webrick/https'
require 'openssl'
require 'socket'
require 'open-uri'
require 'net/http'
require 'json'
require 'securerandom'
require 'rmagick'

require 'sinatra/cross_origin'

if Socket.gethostname == 'tms2.0.local'
  ssl_options = {
    SSLEnable: true,
    SSLCertificate: OpenSSL::X509::Certificate.new(File.open('/home/lit_users/workspace/cert.pem').read),
    SSLPrivateKey: OpenSSL::PKey::RSA.new(File.open('/home/lit_users/workspace/privkey.pem').read)
  }
  set :server_settings, ssl_options
end

# enable :sessions

configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

# helpers do
#   def current_user
#     User.find_by(id: session[:user])
#   end
# end

get '/' do
  'TMS 2.0 API'
end

post '/api/v1' do
  request.body.rewind
  req_data = JSON.parse(request.body.string)
  req_type = req_data["type"]
  if req_type == "sign_up"
    user = User.create(
      mail: req_data["mail"],
      name: req_data["name"],
      password: req_data["password"],
      password_confirmation: req_data["password_confirmation"],
      user_line_id: ""
    )
    if user.persisted? # ユーザー登録成功時はユーザー情報を返す
      # session[:user] = user.id
      res_data = {
        response: "OK",
        id: user.id,
        name: user.name,
        mail: user.mail,
        lineid: user.user_line_id
      }
    else # ユーザー登録失敗時の理由をチェックしそれを返す
      if req_data["password"] != req_data["password_confirmation"]
        res_data = {
          response: "Bad Request",
          reason: "PASSWORD_MISMATCH"
        }
      else
        res_data = {
          response: "Bad Request"
        }
      end
    end
  elsif req_type == "sign_in"
    user = User.find_by(mail: req_data["mail"])
    if user && user.authenticate(req_data["password"])
      # session[:user] = user.id
      res_data = {
        response: "OK",
        id: user.id,
        name: user.name,
        mail: user.mail,
        lineid: user.user_line_id
      }
    else
      res_data = {
        response: "Bad Request"
      }
    end
  elsif req_type == "sign_out"
    session[:user] = nil
    res_data = {
      response: "OK"
    }
  elsif req_type == "set_user_line_id"
  elsif req_type == "set_user_line_notify"
  elsif req_type == "set_user_groups"
  elsif req_type == "create_group"
  elsif req_type == "create_project"
    user = User.find_by(id: req_data["user_id"])
    if user != nil
      project = Project.create(
        name: req_data["name"],
        progress: 0,
        user_id: user.id
      )
      res_data = {
        response: "OK"
      }
      res_data["project"] = project
    else
      res_data = {
        response: "Bad Request",
        reason: "USER_NOT_FOUND"
      }
    end
  elsif req_type == "set_project_visibility"
  elsif req_type == "remove_project"
  elsif req_type == "create_phase"
    user = User.find_by(id: req_data["user_id"])
    if user != nil
      project = Project.find_by(id: req_data["project_id"])
      if project.user_id == user.id
        deadline_date = req_data["deadline"].split('-')
        if deadline_date != nil && req_data["name"] != ""
          if Date.valid_date?(deadline_date[0].to_i, deadline_date[1].to_i, deadline_date[2].to_i)
            phase = Phase.create(
              name: req_data["name"],
              deadline: req_data["deadline"],
              project_id: project.id
            )

            res_data = {
              response: "OK"
            }
            res_data["phase"] = phase
          else
            res_data = {
              response: "Bad Request",
              reason: "DEADLINE_INVALID"
            }
          end
        else
          res_data = {
            response: "Bad Request",
            reason: "DEADLINE_INVALID_OR_NAME_INVALID"
          }
        end
      else
        res_data = {
          response: "Bad Request",
          reason: "USER_MISMATCH"
        }
      end
    else
      res_data = {
        response: "Bad Request",
        reason: "USER_NOT_FOUND"
      }
    end
  elsif req_type == "create_task"
  elsif req_type == "remove_task"
  elsif req_type == "change_task_progress"
    user = User.find_by(id: req_data["user_id"])
    if user != nil
      task = Task.find_by(id: req_data["task_id"])
      if Project.find_by(id: task.project_id).user_id == user.id
        if task != nil
          task.progress = req_data["task_progress"]
          task.save
          update_project_progress(task.project_id)

          # アクティビティ追加処理

          res_data = {
            response: "OK"
          }
        else
          res_data = {
            response: "Bad Request",
            reason: "TASK_NOT_FOUND"
          }
        end
      else
        res_data = {
          response: "Bad Request",
          reason: "USER_MISMATCH"
        }
      end
    else
      res_data = {
         response: "Bad Request",
         reason: "USER_NOT_FOUND"
      }
    end
  elsif req_type == "get_projects"
    user = User.find_by(id: req_data["id"])
    if user != nil
      projects = Project.where(user_id: user.id)
      if projects != nil
        res_data = {
          response: "OK"
        }
        res_data["projects"] = projects
      else
        res_data = {
          response: "Bad Request",
          reason: "PROJECT_NOT_FOUND"
        }
      end
    else
      res_data = {
        response: "Bad Request",
        reason: "USER_NOT_FOUND"
      }
    end
  elsif req_type == "get_project_info"
    project = Project.find_by(id: req_data["project_id"])
    if project != nil
      phases = Phase.where(project_id: req_data["project_id"])
      tasks = Task.where(project_id: req_data["project_id"])
      res_data = {
        response: "OK"
      }
      res_data["project"] = project
      res_data["phases"] = phases
      res_data["tasks"] = tasks
    else
      res_data = {
        response: "Bad Request",
        reason: "PROJECT_NOT_FOUND"
      }
    end
  elsif req_type == "get_groups"
  elsif req_type == "get_group_info"
  elsif req_type == "get_user_info"
  elsif req_type == "line_link"
  elsif req_type == "line_link_completed"
  else
  end
  res_data = res_data.to_json
  json res_data
end

def update_project_progress(id = nil)
  project = Project.find_by(id: id)
  all_tasks = Task.where(project_id: id)
  completed_tasks = all_tasks.where(progress: 100)
  project.progress = calc_project_progress(all_tasks.count, completed_tasks.count)
  project.save
end

def calc_project_progress(all = nil, completed = nil)
  if all == 0
    return 0
  end
  return (completed.to_f / all.to_f * 100)
end