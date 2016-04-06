# frozen_string_literal: true
FactoryGirl.define do
  factory :file, class: Hash do
    name "file.txt"
    additions { rand(0..50) }
    deletions { rand(0..50) }
    changes { additions + deletions }
    initialize_with { attributes }
  end
end
