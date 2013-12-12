require 'net/http'
require 'uri'
require 'open-uri'
require 'json'

class SemaphoreRouting
  def initialize
    @auth_token = ''
    @project_hash = ''
    @base = "https://semaphoreapp.com/api/v1/projects/#{@project_hash}"
  end

  def branches
    URI("#{@base}/branches.json#{auth}")
  end

  def branch_status(id)
    URI("#{@base}/#{id}/status.json#{auth}")
  end

  private

  def auth
    "?auth_token=#{@auth_token}"
  end
end

class Semaphoreapp

  def initialize
    @routing = SemaphoreRouting.new
  end

  def branches


    block = lambda do
      content = open(@routing.branches.to_s).read
      res = JSON.parse(content)

      res.map do |r|
        Branch.new(r)
      end
    end

    @branches ||= block.call
  end

  def branch(name)
    branches.select { |b| b.name == name }.first
  end

end

class Branch
  def initialize(json)
    @routing = SemaphoreRouting.new

    json.each do |k, v|
      instance_variable_set("@#{k}", v)
      instance_eval "def #{k}; '#{v}'; end"
    end
  end

  def status
    block = lambda do
      content = open(@routing.branch_status(id).to_s).read
      res = JSON.parse(content)
      BranchStatus.new(res)
    end
    @status ||= block.call
  end
end

class BranchStatus
  def initialize(json)
    json.each do |k, v|
      instance_variable_set("@#{k}", v)
      instance_eval "def #{k}; '#{v}'; end"
    end
  end
end


class Git
  def self.current_branch
    %x(git rev-parse --abbrev-ref HEAD).strip
  end
end

p Semaphoreapp.new.branch(Git.current_branch).status.result