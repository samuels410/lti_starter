puts 'Creating deafult user'
Role.create([
                { :name => 'admin' },
            ], :without_protection => true)
puts 'SETTING UP DEFAULT USER LOGIN'

user = User.create! :name => 'Administrator', :email => 'lms.admin@arrivusystems.com', :password => 'admin123$', :password_confirmation => 'admin123$'

puts 'User created: ' << user.name

user.add_role :admin
