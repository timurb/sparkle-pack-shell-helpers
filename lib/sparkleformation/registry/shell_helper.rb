SfnRegistry.register(:shell_helper) do |args|
  case args[:part].to_s
  when 'shebang'
    "#!/bin/sh -ex\n\n"

  ## Put the following at the top of your userdata after shebang
  # 'CFN_STACK="',      stack_name!,          "\"\n",
  # 'CFN_RESOURCE="',   "App#{n}Ec2Instance", "\"\n",
  # 'CFN_REGION="',     region!,              "\"\n",
  #
  # Make sure you have cfn-init installed
  when 'cfn_init'
    <<-EOF
    /opt/aws/bin/cfn-init --verbose \\
                          --stack "${CFN_STACK}" \\
                          --resource "${CFN_RESOURCE}" \\
                          --region "${CFN_REGION}"

    EOF

  when 'cfn_signal'
    <<-EOF
    /opt/aws/bin/cfn-signal --exit-code $? \\
                            --stack "${CFN_STACK}" \\
                            --resource "${CFN_RESOURCE}" \\
                            --region "${CFN_REGION}"

    EOF
  else
    raise!("Unknown part #{args[:part].inspect} passed to registry shell_helper")
  end
end
