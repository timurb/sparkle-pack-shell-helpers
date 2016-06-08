# Usage:
#
#   user_data base64!( join!( *registry!(:shell_var, name: "foo", value: "bar" )))
#
#(notice the asterisk!)
#
# After values are joined by CFN the following well-formed shell will be produced:
#   foo="bar"
#
# Use Ref-s and Fn-s as a value
#
SfnRegistry.register(:shell_var) do |args|
  raise!("Parameters 'name' and 'value' must be passed. You've passed #{args.inspect}") \
    unless args[:name] && args[:value]

  ["#{args[:name]}=\"", args[:value], "\"\n"]

end
