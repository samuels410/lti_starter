
  if Rails.env.development?
    @organization = Organization.create(:host => "localhost:3000",
                            'name' => "Arrivu dev lms",
                            'description' => "Arrivu lms",
                            'url' => 'https://arrivu.lvh.me:3000',
                            'image' => 'https://lms.arrivuhiring.com/images/arrivu_logo.png',
                            'email' => 'lms.admin@arrivusystems.com'
    )
  #   Billing types
    @organization.billing_types.create(billing_type: "annually",discount_percentage: '20',months: 12)
    @organization.billing_types.create(billing_type: "half-yearly",discount_percentage: '10',months: 6)
    @organization.billing_types.create(billing_type: "quarterly",discount_percentage: '5',months: 3)
    @organization.billing_types.create(billing_type: "month-by-month",discount_percentage: '0',months: 1)

    #   Feature sets
   @f1= FeatureSet.create(organization_id: @organization.id,
                      name: "Free",
                      no_students: 100,
                      no_teachers: 2,
                      no_admins: 1,
                      no_courses: 2,
                      storage: 1000,
                      unlimited: false)
    @f2= FeatureSet.create(organization_id: @organization.id,
                      name: "Plus",
                      no_students: 500,
                      no_teachers: 100,
                      no_admins: 10,
                      no_courses: 25,
                      storage: 50000,
                      unlimited: false)
    @f3= FeatureSet.create(organization_id: @organization.id,
                      name: "Premium",
                      no_students: 1000,
                      no_teachers: 200,
                      no_admins: 25,
                      no_courses: 200,
                      storage: 1000000,
                      unlimited: false)

    SubscriptionPlan.create(organization_id: @organization.id,
                            feature_set_id: @f1.id,
                            name: 'Free',
                            rate_cents: 0

    )
    SubscriptionPlan.create(organization_id: @organization.id,
                            feature_set_id: @f2.id,
                            name: 'Plus',
                            rate_cents: 10

    )
    SubscriptionPlan.create(organization_id: @organization.id,
                            feature_set_id: @f3.id,
                            name: 'Premium',
                            rate_cents: 100

    )


  end

puts 'Creating deafult user'
Role.create([
                { :name => 'admin' },
            ], :without_protection => true)
puts 'SETTING UP DEFAULT USER LOGIN'

user = User.create! :name => 'Administrator', :email => 'lms.admin@arrivusystems.com', :password => 'admin123$', :password_confirmation => 'admin123$'

puts 'User created: ' << user.name

user.add_role :admin
