# frozen_string_literal: true
FactoryGirl.define do
  factory :pull_request_attributes, class: Hash do
    number 6
    title "title"
    user %w(username user_url)
    updated_at { Time.now.utc }
    organization { Faker::Lorem.word }
    project { Faker::Lorem.word }
    html_url "https://github.com/org/repo/url"
    changes do
      {
        file_types: {
          rb: { additions: 2, deletions: 8 },
          js: { additions: 4, deletions: 4 },
          yaml: { additions: 0, deletions: 12 },
        },
        additions: 6,
        deletions: 24,
        commits: 29,
      }
    end

    trait :different_changes_with_shared_file_types do
      changes do
        {
          file_types: {
            rb: { additions: 12, deletions: 54 },
            js: { additions: 2, deletions: 2 },
            html: { additions: 15, deletions: 4 },
          },
          additions: 29,
          deletions: 60,
          commits: 8,
        }
      end
    end

    trait :different_changes_without_shared_file_types do
      changes do
        {
          file_types: {
            java: { additions: 2, deletions: 8 },
            xml: { additions: 4, deletions: 4 },
          },
          additions: 6,
          deletions: 12,
          commits: 2,
        }
      end
    end

    initialize_with { attributes }
  end
end
