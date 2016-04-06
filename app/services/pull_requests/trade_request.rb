# frozen_string_literal: true
module PullRequests
  class TradeRequest
    attr_reader :pull_request, :needs_suggestions, :organization, :project

    def initialize(request_text:)
      @organization = ENV["default_owner"]
      @needs_suggestions = false
      parse_request_words(request_text.split(" "))
    end

    private

    def parse_request_words(request_words)
      case request_words.size
      when 2
        # prtrade pull_request_url
        unwrapped_link = request_words.second[1...-1] # links for slack are wrapped in < >
        return parse_uri(unwrapped_link) if URI.parse(unwrapped_link).scheme
        # prtrade project_name
        @project = request_words.second
      when 3
        # prtrade project_name pull_request_number
        @pull_request = pull_request_from_pr_number(request_words.second, request_words.third.to_i)
      else
        raise InvalidRequestError
      end
    end

    def parse_uri(uri)
      # extract the owner, project_name and pr_number from the URI
      split_uri = uri.split("/")
      resource_index = split_uri.index("pull") || raise(InvalidPullRequestURLError)
      @organization = split_uri[resource_index - 2]
      project = split_uri[resource_index - 1]
      @pull_request = pull_request_from_pr_number(project, split_uri[resource_index + 1])
    end

    def pull_request_from_pr_number(project_name, pr_number)
      @project = project_name
      @needs_suggestions = true
      pull_request_repository.pull_request(@organization, project_name, pr_number.to_i)
    end

    def pull_request_repository
      @pull_request_repository ||= PullRequestRepository.new
    end
  end
end
