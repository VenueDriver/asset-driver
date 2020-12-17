# Asset Driver

Serverless logic for adding a system of predicate-logic rules, each with triggers and actions, to AWS S3 buckets.  For triggering the processing of asset files when source files are added or updated.

## How it works

Asset Driver is a SAM application that contains a simple script that loads a set of rules and runs them.  Each rule checks the AWS Lambda event to see if it matches.  If a rule matches, then it performs an action.

For example, if the event is for the creation of a new image source file in a source bucket that matches a certain name pattern, then the action could be to process that source image into various resolutions for serving for a web page or web app.

Both the rule and the action are simply Ruby code.  To add or modify rules, iterate the code for the project.  The application doesn't use any storage other than the S3 buckets, so it's simple to operate and maintain.

## Deploying

With SAM, you have to build before you can deploy:

    $ sam build

That bundles the Ruby gems and creates the stuff for SAM to upload to the deployment S3 bucket when you deploy.

SAM can't bind an S3 event to a Lambda function unless the S3 bucket is from the same SAM template.  It can't work with existing buckets.  That means that we need to do some additional work after the SAM deployment to set up the S3 events to trigger the Lambda function.  To run the script that handles all of it:

    $ ruby deploy.rb

That will deploy the default environment, which is set up to use a development bucket for input and output.  The bucket must exist already, and the bucket setup is not handled by this SAM template.

You can optionally pass an environment:

    $ ruby deploy.rb staging
    $ ruby deploy.rb production

The script deploys using SAM, then checks the outputs of the stack to find the ARN for the Lambda function that it just deployed.  Then it uses that to set up the event on the S3 buckets.  The ARNs for the S3 buckets are passed through the SAM template parameters into the stack and will also appear in the output, so that all of the information for each stack is available from CloudFormation.  You can configure the ARNs for the specific S3 buckets that that you want to use in the `samconfig.toml` file.
