# frozen_string_literal: true
module PullRequests
  class Label
    def initialize(label_name)
      @name = label_name.downcase
    end

    def to_s
      @name
    end

    def ==(other)
      @name == other.to_s
    end
  end
end
