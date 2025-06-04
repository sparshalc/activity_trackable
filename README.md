# User Activity Tracking Application  

![image](https://github.com/user-attachments/assets/782791ec-6de5-4ad3-a1bf-6e9175f90e56)

A comprehensive multi-tenant Ruby on Rails application designed to track user activities, manage company teams, and provide recognition systems with detailed analytics.

---

## 📋 Documentation Links

- **📖 [View Full Documentation](docs/USER_ACTIVITY_TRACKING_DOCUMENTATION.md)**
- **🖼️ [Database ERD](docs/ERD.png)**
- **📁 [Documentation Directory](docs/)**

---

## Overview

This application provides organizations with powerful tools to monitor user engagement, track activities, manage teams across multiple companies, and recognize employee achievements. Built with Ruby on Rails 8.0 and featuring modern frontend technologies, it offers real-time activity tracking, role-based access control, and comprehensive analytics.

## Key Features

### 🔍 Activity Tracking

![image](https://github.com/user-attachments/assets/e1470563-0d90-4881-a3e7-6eb1611ac467)

- **Comprehensive Activity Logging**: Automatically tracks user logins, logouts, profile updates, and system interactions
- **Multi-tenant Architecture**: Full isolation between companies with secure data segregation
- **Rich Metadata**: Captures IP addresses, user agents, session duration, and custom metadata
- **Real-time Monitoring**: Live activity feeds and instant notifications

### 👥 User Management

![image](https://github.com/user-attachments/assets/4ca70f4c-f1c9-4763-810e-eff27a44fcc7)


- **Role-based Access Control**: Owner, Admin, Manager, and Employee roles with granular permissions
- **Soft Delete System**: Safe user deactivation with full audit trails
- **Multi-company Support**: Users can belong to multiple organizations
- **Authentication**: Secure user authentication with Devise
- **Profile Management**: Comprehensive user profile system

### 🏢 Company Management

![image](https://github.com/user-attachments/assets/c2fa25f3-37d3-422a-99d1-af52d91c1293)

- **Multi-tenant Architecture**: Complete company isolation using acts_as_tenant
- **Company Settings**: Configurable activity tracking and retention policies
- **Team Management**: Add/remove users, assign roles, manage permissions
- **Company Switching**: Seamless switching between multiple companies
- **Default Setup**: Automatic role and settings creation for new companies

### 🏆 Recognition System

![image](https://github.com/user-attachments/assets/55070906-3cba-4b7d-9615-9e254dcadb57)

- **Peer Recognition**: Employee recognition and appreciation system
- **Activity Integration**: Recognition events are automatically tracked
- **Recognition History**: Complete history of given and received recognitions

### 📊 Analytics & Reporting

![image](https://github.com/user-attachments/assets/273fa164-ecec-4521-9a7a-c71580701975)

- **Interactive Charts**: Powered by Chart.js and Chartkick
- **Activity Analytics**: Detailed insights into user engagement patterns
- **Date Range Filtering**: Flexible time-based analysis
- **User Activity Summaries**: Individual and company-wide activity reports
- **Export Capabilities**: CSV export functionality for reports

### 🔐 Security & Permissions

![image](https://github.com/user-attachments/assets/40282933-7625-4fe4-a626-06d9bb55b6ae)

- **Pundit Authorization**: Fine-grained authorization policies
- **Role-based Permissions**: Hierarchical permission system
- **Data Sanitization**: Automatic removal of sensitive data from activity logs
- **Request Tracking**: Secure request correlation and tracking

### PDF Reporting

![image](https://github.com/user-attachments/assets/7d5a436b-d043-49ee-8882-c11e28585b79)

- **One-click PDF Generation**: Generate reports directly from the analytics page
- **Customizable Date Ranges**: Reports respect the selected date filter
- **Professional Formatting**: Clean, print-ready PDF layout
- **Comprehensive Data**: Includes all analytics metrics, charts data, and statistics

## Technology Stack

### Backend
- **Ruby 3.3+** - Modern Ruby version
- **Rails 8.0.2** - Latest Rails framework
- **PostgreSQL** - Primary database
- **Puma** - Web server
- **Devise** - Authentication
- **Pundit** - Authorization
- **ActsAsTenant** - Multi-tenancy

### Frontend
- **Turbo Rails** - SPA-like experience
- **Stimulus** - Modest JavaScript framework
- **TailwindCSS 4.1** - Modern CSS framework
- **Chart.js** - Interactive charts
- **Chartkick** - Ruby chart integration
- **ESBuild** - JavaScript bundling

### Additional Libraries
- **Pagy** - Efficient pagination
- **Groupdate** - Date grouping for analytics
- **Discard** - Soft delete functionality
- **RequestStore** - Thread-safe request storage
- **Browser** - Browser detection
- **FactoryBot** - Test data generation
- **RSpec** - Testing framework

## Installation & Setup

### Prerequisites
- Ruby 3.3 or higher
- Node.js 18+ (specified in `.node-version`)
- PostgreSQL 12+
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/sparshalc/activity_trackable
   cd user_activity_tracking
   ```

2. **Install dependencies**
   ```bash
   # Install Ruby gems
   bundle install
   
   # Install Node.js dependencies
   yarn install
   ```

3. **Database setup**
   ```bash
   # Create and setup database
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: if seed data exists
   ```

5. **Asset compilation**
   ```bash
   # Build CSS and JavaScript
   yarn build
   yarn build:css
   ```

6. **Start the application**
   ```bash
   # Start all services (Rails + asset watchers)
   bin/dev
   
   # Or start Rails server only
   rails server
   ```

## Configuration

### Company Settings

Administrators can configure:
- Activity tracking enabled/disabled
- Activity retention period (in days)
- Role permissions
- User access controls

## Usage Guide

### Getting Started

1. **First User Registration**: The first user becomes the company owner
2. **Company Setup**: Configure company settings and create additional roles
3. **User Management**: Invite team members and assign appropriate roles
4. **Activity Monitoring**: Monitor team activities through the dashboard
5. **Recognition System**: Start recognizing team achievements
6. **Analytics**: Use analytics to gain insights into team engagement

### User Roles & Permissions

| Feature | Owner | Admin | Manager | Employee |
|---------|--------|--------|----------|-----------|
| Dashboard | ✅ | ✅ | ✅ | ✅ |
| Analytics | ✅ | ✅ | ✅ | ❌ |
| User Management | ✅ | ✅ | View Only | ❌ |
| Activities | ✅ | ✅ | ✅ | Own Only |
| Recognitions | ✅ | ✅ | ✅ | View Only |
| Settings | ✅ | ✅ | ❌ | ❌ |

### API Integration

The application provides REST API endpoints for integration:

```ruby
# Activity
GET /activities.json

# User management
GET /users.json

# Recognitions
GET /recognitions.json

# Analysis
GET /analytics.json

# Company Settings
GET /company_settings.json
```

## Development

### Running Tests

```bash
# Run specific test files
bundle exec rspec spec/models/user_spec.rb
```

### Database Management

```bash
# Create migration
rails generate migration AddColumnToTable column:type

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Reset database
rails db:reset
```
## Troubleshooting

### Common Issues

1. **Assets not loading**: Run `yarn build && yarn build:css`
2. **Database connection**: Check PostgreSQL service status
3. **Permission errors**: Verify user roles and Pundit policies
4. **Activity tracking not working**: Check company settings

### Logs

Application logs are available in:
- `log/development.log` - Development environment
- `log/production.log` - Production environment
- `log/test.log` - Test environment

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Make your changes
4. Add tests for new functionality
5. Run the test suite (`bundle exec rspec`)
6. Commit your changes (`git commit -am 'Add new feature'`)
7. Push to the branch (`git push origin feature/new-feature`)
8. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code comments and tests

---

Built with ❤️ using Ruby on Rails
