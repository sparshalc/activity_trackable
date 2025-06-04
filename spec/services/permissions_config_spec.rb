require 'rails_helper'

RSpec.describe PermissionsConfig do
  describe '::permissions_for' do
    it 'returns owner permissions' do
      permissions = described_class.permissions_for('owner')
      expect(permissions[:users][:view]).to be true
      expect(permissions[:users][:create]).to be true
      expect(permissions[:users][:update]).to be true
      expect(permissions[:users][:delete]).to be true
      expect(permissions[:company_settings][:edit]).to be true
    end

    it 'returns admin permissions' do
      permissions = described_class.permissions_for('admin')
      expect(permissions[:users][:view]).to be true
      expect(permissions[:company_settings][:edit]).to be true
    end

    it 'returns manager permissions' do
      permissions = described_class.permissions_for('manager')
      expect(permissions[:users][:view]).to be true
      expect(permissions[:users][:update]).to be false
      expect(permissions[:company_settings][:edit]).to be false
    end

    it 'returns employee permissions' do
      permissions = described_class.permissions_for('employee')
      expect(permissions[:users][:view]).to be false
      expect(permissions[:analytics][:view]).to be false
      expect(permissions[:dashboard][:view]).to be true
    end

    it 'returns default permissions for unknown role' do
      permissions = described_class.permissions_for('unknown_role')
      expect(permissions).to eq(described_class::DEFAULT_PERMISSIONS)
    end
  end

  describe '::default_permissions' do
    it 'returns a deep copy of default permissions' do
      permissions1 = described_class.default_permissions
      permissions2 = described_class.default_permissions

      expect(permissions1).to eq(permissions2)
      expect(permissions1).not_to be(permissions2) # Different objects
    end

    it 'has expected structure' do
      permissions = described_class.default_permissions

      expect(permissions).to include(
        :dashboard, :analytics, :users, :activities,
        :recognitions, :company_settings, :user_profile, :company_switcher
      )
    end
  end

  describe '::available_resources' do
    it 'returns all resource keys' do
      resources = described_class.available_resources
      expect(resources).to include(
        :dashboard, :analytics, :users, :activities,
        :recognitions, :company_settings, :user_profile, :company_switcher
      )
    end
  end

  describe '::available_actions' do
    it 'returns actions for users resource' do
      actions = described_class.available_actions(:users)
      expect(actions).to eq([ :view, :create, :update, :delete ])
    end

    it 'returns actions for dashboard resource' do
      actions = described_class.available_actions(:dashboard)
      expect(actions).to eq([ :view ])
    end

    it 'returns empty array for unknown resource' do
      actions = described_class.available_actions(:unknown)
      expect(actions).to eq([])
    end
  end

  describe '::valid_permission?' do
    it 'returns true for valid resource/action combinations' do
      expect(described_class.valid_permission?(:users, :view)).to be true
      expect(described_class.valid_permission?(:dashboard, :view)).to be true
      expect(described_class.valid_permission?(:company_settings, :edit)).to be true
    end

    it 'returns false for invalid resource/action combinations' do
      expect(described_class.valid_permission?(:users, :invalid)).to be false
      expect(described_class.valid_permission?(:unknown, :view)).to be false
      expect(described_class.valid_permission?(:dashboard, :edit)).to be false
    end
  end

  describe '::available_roles' do
    it 'returns all defined role names' do
      roles = described_class.available_roles
      expect(roles).to eq([ 'owner', 'admin', 'manager', 'employee' ])
    end
  end

  describe '::permissions_diff' do
    let(:old_permissions) do
      {
        'users' => { 'view' => false, 'create' => false },
        'dashboard' => { 'view' => true }
      }
    end

    let(:new_permissions) do
      {
        'users' => { 'view' => true, 'create' => false },
        'dashboard' => { 'view' => true }
      }
    end

    it 'returns differences between permission sets' do
      diff = described_class.permissions_diff(old_permissions, new_permissions)

      expect(diff['users']['view']).to eq({ from: false, to: true })
      expect(diff).not_to have_key('dashboard') # No change
    end

    it 'returns empty hash when permissions are the same' do
      diff = described_class.permissions_diff(old_permissions, old_permissions)
      expect(diff).to be_empty
    end
  end

  describe '::valid_permissions?' do
    it 'returns true for valid permission structure' do
      valid_permissions = {
        'users' => { 'view' => true, 'create' => false },
        'dashboard' => { 'view' => true }
      }

      expect(described_class.valid_permissions?(valid_permissions)).to be true
    end

    it 'returns false for invalid resource' do
      invalid_permissions = {
        'invalid_resource' => { 'view' => true }
      }

      expect(described_class.valid_permissions?(invalid_permissions)).to be false
    end

    it 'returns false for invalid action' do
      invalid_permissions = {
        'users' => { 'invalid_action' => true }
      }

      expect(described_class.valid_permissions?(invalid_permissions)).to be false
    end

    it 'returns false for non-boolean values' do
      invalid_permissions = {
        'users' => { 'view' => 'yes' }
      }

      expect(described_class.valid_permissions?(invalid_permissions)).to be false
    end

    it 'returns false for non-hash input' do
      expect(described_class.valid_permissions?('invalid')).to be false
      expect(described_class.valid_permissions?(nil)).to be false
    end
  end

  describe '::complete_permissions' do
    it 'generates complete permission set with defaults' do
      result = described_class.complete_permissions

      # Should have all resources
      described_class.available_resources.each do |resource|
        expect(result).to have_key(resource.to_s)

        # Should have all actions for each resource
        described_class.available_actions(resource).each do |action|
          expect(result[resource.to_s]).to have_key(action.to_s)
          expect(result[resource.to_s][action.to_s]).to be_in([ true, false ])
        end
      end
    end

    it 'merges with provided base permissions' do
      base = { 'users' => { 'view' => true } }
      result = described_class.complete_permissions(base)

      expect(result['users']['view']).to be true
      expect(result['users']['create']).to be false # Default value
    end
  end

  describe 'ROLE_PERMISSIONS constant' do
    it 'has permissions for all available roles' do
      described_class.available_roles.each do |role|
        expect(described_class::ROLE_PERMISSIONS).to have_key(role)
        expect(described_class::ROLE_PERMISSIONS[role]).to be_a(Hash)
      end
    end

    it 'all role permissions are valid' do
      described_class::ROLE_PERMISSIONS.each do |role, permissions|
        expect(described_class.valid_permissions?(permissions)).to be true
      end
    end
  end

  describe 'consistency checks' do
    it 'DEFAULT_PERMISSIONS structure matches RESOURCES' do
      described_class::RESOURCES.each do |resource, actions|
        expect(described_class::DEFAULT_PERMISSIONS).to have_key(resource)

        actions.each do |action|
          expect(described_class::DEFAULT_PERMISSIONS[resource]).to have_key(action)
        end
      end
    end

    it 'all ROLE_PERMISSIONS have consistent structure' do
      described_class::ROLE_PERMISSIONS.each do |role, permissions|
        described_class::RESOURCES.each do |resource, actions|
          expect(permissions).to have_key(resource),
            "Role #{role} missing resource #{resource}"

          actions.each do |action|
            expect(permissions[resource]).to have_key(action),
              "Role #{role} missing action #{resource}.#{action}"
          end
        end
      end
    end
  end
end
