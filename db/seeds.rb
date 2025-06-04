puts "🌱 Starting seed process..."

if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  Activity.destroy_all
  Recognition.destroy_all
  CompanyUserRole.destroy_all
  CompanyUser.destroy_all
  Role.destroy_all
  CompanySetting.destroy_all
  Company.destroy_all
  User.destroy_all
end

puts "🏢 Creating companies..."

companies = [
  { name: "Acme Corporation" },
  { name: "TechStart Inc" },
  { name: "Global Solutions Ltd" }
]

companies.each do |company_data|
  Company.find_or_create_by!(name: company_data[:name])
end

company1 = Company.find_by(name: "Acme Corporation")
company2 = Company.find_by(name: "TechStart Inc")
company3 = Company.find_by(name: "Global Solutions Ltd")

puts "✅ Created #{Company.count} companies"

# 2. Create Roles for each company
puts "👥 Creating roles..."

role_definitions = [
  { name: 'owner', description: 'Company owner with full access' },
  { name: 'admin', description: 'Administrator with management access' },
  { name: 'manager', description: 'Team manager with limited admin access' },
  { name: 'employee', description: 'Regular employee' }
]

Company.find_each do |company|
  role_definitions.each do |role_def|
    Role.find_or_create_by!(
      name: role_def[:name],
      company: company
    ) do |role|
      role.description = role_def[:description]
      role.permissions = case role_def[:name]
      when "owner", "admin"
        {
          dashboard: { view: true },
          analytics: { view: true },
          users: { view: true, create: true, update: true, delete: true },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: true, edit: true },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      when "manager"
        {
          dashboard: { view: true },
          analytics: { view: true },
          users: { view: true, update: false },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: false, edit: false },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      else # employee
        {
          dashboard: { view: true },
          analytics: { view: false },
          users: { view: false, create: false, update: false, delete: false },
          activities: { view: true },
          recognitions: { view: true, create: false },
          company_settings: { view: false, edit: false },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end
  end
end

puts "✅ Created #{Role.count} roles"

# 3. Create Users with default employee role
puts "👤 Creating users..."

users_data = [
  {
    email: "admin1@example.com",
    password: "password123",
    full_name: "Admin One",
    companies: [
      { company: company1, role: "admin" },    # Admin at Acme Corporation
      { company: company2, role: "employee" }  # Employee at TechStart Inc
    ]
  },
  {
    email: "admin2@example.com",
    password: "password123",
    full_name: "Admin Two",
    companies: [
      { company: company2, role: "admin" },    # Admin at TechStart Inc
      { company: company3, role: "manager" }  # manager at Global Solutions Ltd
    ]
  },
  {
    email: "admin3@example.com",
    password: "password123",
    full_name: "Admin Three",
    companies: [
      { company: company3, role: "admin" },    # Admin at Global Solutions Ltd
      { company: company1, role: "employee" }  # Employee at Acme Corporation
    ]
  },
  # Regular employee users
  {
    email: "john.doe@acme.com",
    password: "password123",
    full_name: "John",
    company: company1
  },
  {
    email: "jane.smith@acme.com",
    password: "password123",
    full_name: "Jane",
    company: company1
  },
  {
    email: "bob.wilson@techstart.com",
    password: "password123",
    full_name: "Bob",
    company: company2
  },
  {
    email: "alice.brown@techstart.com",
    password: "password123",
    full_name: "Alice",
    company: company2
  },
  {
    email: "mike.jones@global.com",
    password: "password123",
    full_name: "Mike",
    company: company3
  }
]

users_data.each do |user_data|
  if user_data[:companies]
    # Multi-company user (admin users)
    # Set the first company as the default tenant before creating the user
    ActsAsTenant.current_tenant = user_data[:companies].first[:company]

    # Create the user
    user = User.find_or_create_by!(email: user_data[:email]) do |u|
      u.password = user_data[:password]
      u.password_confirmation = user_data[:password]
      u.full_name = user_data[:full_name]
    end

    user_data[:companies].each do |company_data|
      # Set the current tenant to the company before creating associations
      ActsAsTenant.current_tenant = company_data[:company]

      # Create CompanyUser association
      company_user = CompanyUser.find_or_create_by!(
        user: user,
        company: company_data[:company]
      )

      # Find the role for this company
      user_role = Role.find_by(name: company_data[:role], company: company_data[:company])

      # Create CompanyUserRole with the specified role
      CompanyUserRole.find_or_create_by!(
        company_user: company_user,
        role: user_role
      )

      # Set current_role
      company_user.update!(current_role: user_role)

      puts "  👤 Created user: #{user.full_name} (#{user.email}) with #{company_data[:role]} role at #{company_data[:company].name}"
    end
  else
    # Single-company user (regular employees)
    # Set the current tenant to the user's company before creating the user
    ActsAsTenant.current_tenant = user_data[:company]

    # Create the user
    user = User.find_or_create_by!(email: user_data[:email]) do |u|
      u.password = user_data[:password]
      u.password_confirmation = user_data[:password]
      u.full_name = user_data[:full_name]
    end

    # Create CompanyUser association
    company_user = CompanyUser.find_or_create_by!(
      user: user,
      company: user_data[:company]
    )

    # Determine the role based on user_data (admin if specified, otherwise employee)
    role_name = user_data[:role] || 'employee'
    user_role = Role.find_by(name: role_name, company: user_data[:company])

    # Create CompanyUserRole with the determined role
    CompanyUserRole.find_or_create_by!(
      company_user: company_user,
      role: user_role
    )

    # Set current_role
    company_user.update!(current_role: user_role)

    puts "  👤 Created user: #{user.full_name} (#{user.email}) with #{role_name} role at #{user_data[:company].name}"
  end
end

puts "✅ Created #{User.count} users with default employee roles"

puts "🎉 Seed process completed successfully!"
