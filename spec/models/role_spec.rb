require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:company) { create(:company) } # Don't use :with_settings to avoid default roles

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:role, company: company)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:role, :owner, company: company, name: 'test_owner')).to be_valid
      expect(build(:role, :admin, company: company, name: 'test_admin')).to be_valid
      expect(build(:role, :manager, company: company, name: 'test_manager')).to be_valid
      expect(build(:role, :employee, company: company, name: 'test_employee')).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:role, company: company, name: 'test_role') }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires a unique name within company scope' do
      create(:role, name: 'unique_admin', company: company)

      duplicate_role = build(:role, name: 'unique_admin', company: company)
      expect(duplicate_role).not_to be_valid
      expect(duplicate_role.errors[:name]).to include('has already been taken')
    end

    it 'allows same name in different companies' do
      company1 = create(:company)
      company2 = create(:company)

      ActsAsTenant.with_tenant(company1) do
        create(:role, name: 'cross_company_admin', company: company1)
      end

      ActsAsTenant.with_tenant(company2) do
        new_role = build(:role, name: 'cross_company_admin', company: company2)
        expect(new_role).to be_valid
      end
    end

    it 'requires permissions (set by callback)' do
      # The callback sets default permissions, so this should always be valid
      subject.permissions = nil
      subject.valid? # This triggers the callback
      expect(subject.permissions).to be_present
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:company_user_roles).dependent(:restrict_with_error) }
    it { should have_many(:company_users).through(:company_user_roles) }
    it { should have_many(:current_role_users).class_name('CompanyUser').with_foreign_key(:current_role_id) }
    it { should belong_to(:company) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets default permissions if none provided' do
        role = build(:role, company: company, name: 'callback_test', permissions: nil)
        role.valid?
        role.save!
        expect(role.permissions).to eql(Role::DEFAULT_PERMISSIONS.deep_dup.deep_stringify_keys)
      end

      it 'does not override existing permissions' do
        custom_permissions = { "users" => { "view" => true } }
        role = build(:role, company: company, name: 'custom_test', permissions: custom_permissions)
        role.valid?
        expect(role.permissions).to eq(custom_permissions)
      end
    end
  end

  describe '#can?' do
    let(:role) { create(:role, company: company, name: 'test_admin_role', permissions: admin_permissions) }
    let(:admin_permissions) do
      {
        "users" => { "view" => true, "create" => true, "update" => true, "delete" => false },
        "activities" => { "view" => true, "export" => false }
      }
    end

    it 'returns true for allowed permissions' do
      expect(role.can?(:users, :view)).to be true
      expect(role.can?(:users, :create)).to be true
    end

    it 'returns false for denied permissions' do
      expect(role.can?(:users, :delete)).to be false
      expect(role.can?(:activities, :export)).to be false
    end

    it 'returns false for non-existent permissions' do
      expect(role.can?(:nonexistent, :action)).to be false
    end

    it 'handles string and symbol arguments' do
      expect(role.can?('users', 'view')).to be true
      expect(role.can?(:users, :view)).to be true
    end
  end

  describe '#update_permission' do
    let(:role) { create(:role, company: company, name: 'update_test_role') }

    it 'updates existing permission' do
      expect {
        role.update_permission(:users, :view, true)
      }.to change { role.reload.permissions['users']['view'] }.to(true)
    end

    it 'creates new resource permissions' do
      role.update_permission(:new_resource, :action, true)
      expect(role.permissions['new_resource']['action']).to be true
    end

    it 'saves the role after updating' do
      expect(role).to receive(:save).and_return(true)
      role.update_permission(:users, :view, true)
    end
  end

  describe 'role traits' do
    describe 'owner role' do
      let(:role) { build(:role, :owner, company: company, name: 'trait_owner') }

      it 'has correct name and description' do
        expect(role.name).to eq('trait_owner')
        expect(role.description).to include('Owner role')
      end

      it 'has full permissions' do
        expect(role.can?(:users, :view)).to be true
        expect(role.can?(:users, :create)).to be true
        expect(role.can?(:users, :update)).to be true
        expect(role.can?(:users, :delete)).to be true
      end
    end

    describe 'admin role' do
      let(:role) { build(:role, :admin, company: company, name: 'trait_admin') }

      it 'has correct name and description' do
        expect(role.name).to eq('trait_admin')
        expect(role.description).to include('Admin role')
      end

      it 'has administrative permissions' do
        expect(role.can?(:users, :view)).to be true
        expect(role.can?(:users, :create)).to be true
      end
    end

    describe 'manager role' do
      let(:role) { build(:role, :manager, company: company, name: 'trait_manager') }

      it 'has correct name and description' do
        expect(role.name).to eq('trait_manager')
        expect(role.description).to include('Manager role')
      end

      it 'has limited permissions' do
        expect(role.can?(:users, :view)).to be true
        expect(role.can?(:users, :update)).to be false
        expect(role.can?(:company, :update)).to be false
      end
    end

    describe 'employee role' do
      let(:role) { build(:role, :employee, company: company, name: 'trait_employee') }

      it 'has correct name and description' do
        expect(role.name).to eq('trait_employee')
        expect(role.description).to include('Employee role')
      end

      it 'has basic permissions' do
        expect(role.can?(:activities, :view)).to be true
        expect(role.can?(:users, :view)).to be false
        expect(role.can?(:users, :create)).to be false
      end
    end
  end

  describe 'constants' do
    it 'defines default permissions structure' do
      expect(Role::DEFAULT_PERMISSIONS).to include(
        :activities,
        :users,
        :company,
        :roles
      )

      expect(Role::DEFAULT_PERMISSIONS[:users]).to include(
        view: false,
        create: false,
        update: false,
        delete: false
      )
    end
  end

  describe 'dependent restrictions' do
    let(:company_with_settings) { create(:company, :with_settings) }
    let(:user) { create(:user) }
    let(:role) { company_with_settings.roles.find_by(name: 'admin') }

    it 'allows deletion when no company_user_roles exist and not current_role' do
      # Remove the user from the role
      role.company_user_roles.destroy_all

      # Also need to remove any current_role references
      CompanyUser.where(current_role: role).update_all(current_role_id: nil)

      expect { role.destroy! }.not_to raise_error
    end
  end
end
