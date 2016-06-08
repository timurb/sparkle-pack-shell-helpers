SfnRegistry.register(:shell_install) do |args|
  if args[:os].nil?
    raise!(":os parameter is required for registry \"shell_install\"")
  end

  if args[:source].nil?
    raise!("Param :source is required for registry \"shell_install\".")
  end

  case args[:part]
  when :cfn_init, 'install_cfn'
    case args[:os]
    when :redhat, :centos, 'redhat', 'centos'
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

  when :codedeploy
    if args[:ruby].nil?
      raise!("Param :ruby is required for part :codedeploy of registry \"shell_install\".")
    end
    case args[:os]
    when :redhat, :centos, 'redhat', 'centos'
      <<-EOF
      # AWS CodeDeploy requires Ruby 2.0+ available as /usr/bin/ruby2.0
      ln -s #{args[:ruby]} /usr/bin/ruby2.0 ||:

      yum install -y #{args[:source]}\n
      EOF
    else
      raise!("Unknown os #{args[:os].inspect} passed to registry shell_helper")
    end
  else
    raise!("Unknown part #{args[:part].inspect} passed to registry \"shell_install\"")
  end
end
