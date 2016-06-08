# sparkle-pack-shell-helpers

This is SparklePack to be used with SparkleFormation.

Shell helpers to be used in UserData templates for easier generation of shell scripts.

## Usage
Add the pack to your Gemfile and .sfn:

Gemfile:
```ruby
source 'https://rubygems.org'

gem 'sfn'
gem 'sparkle-pack-shell-helpers'
```

.sfn:
```ruby
Configuration.new do
  sparkle_pack [ 'sparkle-pack-shell-helpers' ]
  ...
end
```

In a SparkleFormation Dynamic for EC2 creation:
```ruby
user_data base64!( join!(
  registry!(:shell_helper, part: :shebang),

  *registry!(:shell_var, name: 'CFN_STACK', value: stack_name!),
  *registry!(:shell_var, name: 'CFN_RESOURCE', value: "DemoEc2Instance"),
  *registry!(:shell_var, name: 'CFN_REGION', value: region!),

  "echo Hey!\n"

  registry!(:shell_helper, part: :cfn_init),
))
```

This produces the following UserData:

```json
"UserData": {
  "Fn::Base64": {
    "Fn::Join": [
      "",
      [
        "#!/bin/sh -ex\n\n",
        "CFN_STACK=\"",
        {
          "Ref": "AWS::StackName"
        },
        "\"\n",
        "CFN_RESOURCE=\"",
        "DemoEc2Instance",
        "\"\n",
        "CFN_REGION=\"",
        {
          "Ref": "AWS::Region"
        },
        "\"\n",
        "/opt/aws/bin/cfn-init --verbose \\                         --stack \"${CFN_STACK}\" \\                         --resource \"${CFN_RESOURCE}\" \\                         --region \"${CFN_REGION}\"\n"
      ]
    ]
  }
}
```

This results into the following Cloud-Init shell script (given your stack is named "test" and is run in "us-west-1" region:

```bash
#!/bin/sh -ex

CFN_STACK="test-stack"
CFN_RESOURCE="DemoEc2Instance"
CFN_REGION="us-west-1"

echo Hey!

/opt/aws/bin/cfn-init --verbose \\
                      --stack "${CFN_STACK}" \\
                      --resource "${CFN_RESOURCE}" \\
                      --region "${CFN_REGION}"
```

*Note:* Make sure you have `cfn-init` installed on instance.

## Contributions

Pull requests and bug reports are welcome.

## License and authors

* License: MIT
* Author: Timur Batyrshin <erthad@gmail.com>
