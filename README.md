# PR Trade
[![](http://img.shields.io/codeclimate/github/netguru/prtrade.svg?style=flat-square)](https://codeclimate.com/github/netguru/prtrade) [![](http://img.shields.io/codeclimate/coverage/github/netguru/prtrade.svg?style=flat-square)](https://codeclimate.com/github/netguru/prtrade) [![](http://img.shields.io/gemnasium/netguru/prtrade.svg?style=flat-square)](https://gemnasium.com/netguru/prtrade)
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
============

PR Trade is a Slack integration for company's internal code review process. It allows developers to review each other's work by "trading" it. For a given pull request, the application will fetch all pull requests in the organization that are labeled as ready for review (the label itself can be customized) and display trading suggestions based on the file types and amount of changes in the traded pull request.

Example of usage:
- Start a pull request and label it as ready for review.
- In the dedicated Slack channel, type ```prtrade PROJECT_NAME PULL_REQUEST_NUMBER``` or ```prtrade PULL_REQUEST_URL``` (you can also display all pull request that are ready to be reviewed in a certain project by issuing ```prtrade PROJECT_NAME```)
- The application will display trading suggestions for you, all you need to do now is contact the right person and ask for code review.

### Technology stack
- Ruby 2.3.0
- Rails 4.2.6
- RSpec 3.4.4 for testing
- Memcached for storage

## Prerequisites
- You will need a Github's personal API token. Either generate one or ask other developer for the company's token.
- Your Github organization will also need to setup a webhook that will trigger on the "Pull Request" event (Pull request opened, closed, assigned, labeled, or synchronized).

## Slack Setup
- Go to ```https://COMPANY-NAME.slack.com/apps/manage/custom-integrations```.
- Select ```Outgoing WebHooks``` and click ```Add Outgoing WebHook```.
- Select the channel you want to have it integrated with.
- Put ```prtrade``` into trigger world field.
- Put ```https://YOUR-DOMAIN.COM/api/v1/pull_requests/status``` into URL field.

## Installation
- Clone the repository and ```cd``` to it's directory.
- Run ```bundle install``` (requires [Bundler](http://bundler.io/))
- Install memcached (e.g. by running ```brew install memcached```)

## Application Setup
##### Just run ```bin/setup```
##### or do the steps below:
- ```cp config/application.yml.sample  config/application.yml```.

###### Fill the necessary values in ```config/application.yml```
- ```secret_key_base``` - run ```rake secret``` and paste it here.
- ```github_api_token``` - personal token for Github API
- ```github_webhook_secret``` - it has to match the secret for the webhook on Github.
- ```slack_api_token``` - it's the token from the Slack webhook.
- ```default_owner``` - Github organization that is the default owner of traded repositories
- ```review_label``` - Only pull requests labeled with this label will be fetched by the application as ready for review.
- ```bot_name``` - The name of the Slack bot that will post the suggestions for trade.
- ```usage_bot_name``` -  The name of the Slack bot that will post the correct usage of the application.
- ```icon_emoji``` - Slack bot's avatar will be the emoji specified here.
- ```usage_icon_emoji``` - Slack bot's avatar will change to the one specified here when showing the correct usage of the application.
- ```error_icon_emoji``` -  Slack bot's avatar will change to the one specified here when an error will occur.
- ```max_suggestions``` -  The maximum number of suggestions that will be displayed.
- optionally, set both ```rollbar_token``` and ```newrelic_token```.

## Running / Development
- run ```memcached```
- start the server with ```rails s```
- while working on the code, have ```bin/guard``` running at all times.

### Running Tests
- Simply run ```rspec```
