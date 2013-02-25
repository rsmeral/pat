require_relative '../message'

class GithubRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    payload = event.data["payload"]
    repo = ", repo " + event.data["repo"]["name"]
    case event.data["type"]
      when /Comment/
        action = "commented on"
        content = payload["comment"]["body"]
        object = case event.data["type"]
          when "CommitCommentEvent"; "commit"
          when "IssueCommentEvent"; "issue \#" +  payload["issue"]["number"].to_s
          when "PullRequestReviewCommentEvent"; "pull request"
        end
      when "CreateEvent"
        action = "created"
        object =  payload["ref_type"] + " " +  payload["ref"]
      when "DeleteEvent"
        action = "deleted"
        object =  payload["ref_type"] + " " +  payload["ref"]
      when "ForkEvent"
        action = "forked"
        object = "repository "
        repo = event.data["repo"]["name"]
      when "IssuesEvent"
        action = payload["action"]
        object = "issue \#" +  payload["issue"]["number"].to_s
        content = payload["issue"]["body"]
      when "PullRequestEvent"
        action = payload["action"]
        object = "pull request \#" +  payload["number"].to_s
        content = payload["pull_request"]["body"]
      when "PushEvent"
        action = "pushed "
        action += payload["size"].to_s + " commits " if verbose
        action += "to"
        object = "repository "
        content = payload["commits"][0]["message"]
        repo = event.data["repo"]["name"]
    end
    object.to_s.lstrip
    ret = Message.new
    ret.header = "#{action.to_s.capitalize} #{object}#{repo}"
    if verbose && !content.nil?
      ret.content = content
    end

    ret
  end
end