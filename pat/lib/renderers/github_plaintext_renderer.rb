require_relative 'plaintext_renderer_helper'

class GithubPlaintextRenderer

  attr_accessor :verbose

  include PlaintextRendererHelper

  def initialize(verbose)
    @verbose = verbose
  end

  def process_event(event)
    payload = event.data["payload"]
    repo = ", repo " + event.data["repo"]["name"]
    content = ""
    case event.data["type"]
      when /Comment/
        action = "commented on"
        content = payload["comment"]["body"]
      when "CommitCommentEvent"
        object = "commit"
      when "CreateEvent"
        action = "created"
        object =  payload["ref_type"] + " " +  payload["ref"]
      when "DeleteEvent"
        action = "deleted"
        object =  payload["ref_type"] + " " +  payload["ref"]
      # when "DownloadEvent"
      # when "FollowEvent"
      when "ForkEvent"
        action = "forked"
        object = "repository "
        repo = event.data["repo"]["name"]
      # when "ForkApplyEvent"
      # when "GistEvent"
      # when "GollumEvent"
      when "IssueCommentEvent"
        object = "issue \#" +  payload["issue"]["number"].to_s
      when "IssuesEvent"
        action = payload["action"]
        object = "issue \#" +  payload["issue"]["number"].to_s
        content = payload["issue"]["body"]
      # when "MemberEvent"
      # when "PublicEvent"
      when "PullRequestEvent"
        action = payload["action"]
        object = "pull request \#" +  payload["number"].to_s
        content = payload["pull_request"]["body"]
      when "PullRequestReviewCommentEvent"
        object = "pull request"
        content =  payload["comment"]["body"] if verbose
      when "PushEvent"
        action = "pushed "
        action += payload["size"].to_s + " commits " if verbose
        action += "to"
        object = "repository "
        content = payload["commits"][0]["message"]
        repo = event.data["repo"]["name"]
      # when "TeamAddEvent"
      # when "WatchEvent"
    end
    object.lstrip

    ret = "#{action.capitalize} #{object}#{repo}"
    if verbose && !content.empty?
      ret += "\nMessage:\n#{content}"
    end

    ret
  end
end