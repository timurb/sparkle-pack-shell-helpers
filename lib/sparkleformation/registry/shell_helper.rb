SfnRegistry.register(:shell_helper) do |args|
  case args[:part]
  when :shebang
    "#!/bin/sh -ex\n\n"

  when :install_cfn
    case args[:os]
    when :redhat, :centos
      raise!("Param :source is required. You passed #{args.inspect}.") unless args[:source]
      <<-EOF

      yum install -y epel-release
      yum install -y #{args[:source]}

      # Now fix the cfn-hup script and copy to init.d location as AWS does not do it for you
      cp -f "$(rpm -ql aws-cfn-bootstrap | grep init/redhat/cfn-hup)" /etc/init.d/ ||:
      chmod 0755 /etc/init.d/cfn-hup
      chkconfig --add cfn-hup\n
      EOF
    else
      raise!("Unknown os #{args[:os].inspect} passed to registry shell_helper")
    end

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
    raise!("Unknown part #{args[:part].inspect} passed to registry shell_helper")
  end
end
