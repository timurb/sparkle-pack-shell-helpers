SfnRegistry.register(:shell_helper) do |args|
  case args[:part].to_s
  when 'shebang'
    case args[:shell].to_s
    when 'sh'
      shell = 'sh'
    when 'bash'
      shell = 'bash'
    else
      shell = 'bash'
    end

    if args[:catch_errors]
      "#!/bin/#{shell} -ex\n\n"
    else
      "#!/bin/#{shell} -x\n\n"
    end

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

  when 'add_user'
    if !args[:user]
      raise!("Parameter :user is required. You've passed: #{args.inspect}")
    end

    lines = ["useradd -m #{args[:user]}"]
    if args[:sudo]
      if args[:nopasswd]
        lines << "echo '#{args[:user]} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-#{args[:user]}"
      else
        lines << "echo '#{args[:user]} ALL=(ALL) ALL' > /etc/sudoers.d/90-#{args[:user]}"
      end
    end
    lines.join("\n") + "\n\n"

  when 'no_requiretty'
    "echo 'Defaults !requiretty' > /etc/sudoers.d/99-requiretty\n\n"

  else
    raise!("Unknown part #{args[:part].inspect} passed to registry shell_helper")
  end
end
