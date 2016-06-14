# sparkle-pack-shell-helpers

This is SparklePack to ease shell scripting in UserData.
It is in experimental state, use at your own risk.

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

  "echo Hey!\n",

  registry!(:shell_helper, part: 'cfn_init')
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
        "echo Hey!\n",
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

## Available registries

All the registries are intended to use as elements of `join!()` call.

### shell_var

Produces shell-style variable assignment with trailing newline:
```bash
FOO="BAR"
```

Requires 2 paramers: "name" and "value".

The registry must be called from within `join!()` block and prepended by asterisk `*`:
```ruby
# produces bash snippet as in the above example
user_data base64!( join!( *registry!(:shell_var, name: 'FOO', value: 'BAR' ))
```

The registry returns array of values so calling that differently will produce incorrect results.


### shell_helper

This registry consists of several parts passed as registry params.

Example: `registry(:shell_helper, part: 'shebang')`

Each part produces shell snippet accordingly.

#### part: 'shebang'
Produces shebang `#!/bin/sh -x`

Set parameter `:catch_errors` to true to produce `#!/bin/sh -ex` instead.

#### part: 'cfn_init'
Produces snippet to invoke `cfn_init` with params "stack", "resource" and "region" accordingly set by `shell_var` helper


### shell_install

This registry is used for installation of various AWS related stuff.

*Note:* Refs and Fns don't work inside this function calls!

#### part: 'cfn_init'
Produces snippet to install cfn-init to the target node.
It requires a few parameters:
* `os: 'centos'` -- OS you run. Only `centos` and `redhat` are supported at the moment.
* `source: 'aws-cfn-bootstrap'` -- this string will be passed to the package manager associated with OS. For yum it can be HTTP url.

#### part: 'codedeploy'
Produces snippet to install codedeploy agent to the target node.
It requires a few parameters:
* `os: 'centos'` -- OS you run. Only `centos` and `redhat` are supported at the moment.
* `source: 'aws-cfn-bootstrap'` -- this string will be passed to the package manager associated with OS. For yum it can be HTTP url.
* `ruby: '/opt/ruby/bin/ruby'` -- link this ruby to `/usr/bin/ruby2.0` as required by codedeploy agent. No ruby installation is done -- you need to have it already installed.

Example:
```ruby
registry!(:shell_install,
          part: 'cfn_init',
          os: 'centos',
          source: 'https://s3-us-west-1.amazonaws.com/xxx-rpm/aws-cfn-bootstrap-1.4-8.3.el7.centos.noarch.rpm'),
registry!(:shell_install,
          part: 'codedeploy',
          os: 'centos',
          ruby: '/opt/ruby-2.2.1/bin/ruby',
          source: 'https://s3-us-west-1.amazonaws.com/aws-codedeploy-us-west-1/latest/codedeploy-agent.noarch.rpm'),
registry!(:shell_helper, part: 'cfn_init')
```

## Contributions

Pull requests and bug reports are welcome.

## License and authors

* License: MIT
* Author: Timur Batyrshin <erthad@gmail.com>
