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

## Available registries

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

* Params: `part: :shebang` -- produces shebang `#!/bin/sh -ex`
* Params: `part: :cfn_init` -- produces line to invoke `cfn_init` with params "stack", "resource" and "region" accordingly set by `shell_var` helper


## Contributions

Pull requests and bug reports are welcome.

## License and authors

* License: MIT
* Author: Timur Batyrshin <erthad@gmail.com>
