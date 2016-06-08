SfnRegistry.register(:shell_helper) do |args|
  case args[:part]
  when :shebang
    "#!/bin/sh -ex\n\n"

  ## Put the following at the top of your userdata after shebang
  # 'CFN_STACK="',      stack_name!,          "\"\n",
  # 'CFN_RESOURCE="',   "App#{n}Ec2Instance", "\"\n",
  # 'CFN_REGION="',     region!,              "\"\n",
  #
  # Make sure you have cfn-init installed

  when :cfn_init
    <<-EOF
    /opt/aws/bin/cfn-init --verbose \\
                          --stack "${CFN_STACK}" \\
                          --resource "${CFN_RESOURCE}" \\
                          --region "${CFN_REGION}"\n
    EOF
  else
    raise!("Unknown part #{args[:part].inspect} passed to registry userdata")
  end
end
