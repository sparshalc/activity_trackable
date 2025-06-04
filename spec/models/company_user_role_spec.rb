require 'rails_helper'

RSpec.describe CompanyUserRole, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:company_user_role)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:company_user_role, :admin_assignment)).to be_valid
      expect(build(:company_user_role, :manager_assignment)).to be_valid
      expect(build(:company_user_role, :employee_assignment)).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:company_user_role) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires unique role per company_user' do
      existing = create(:company_user_role)
      subject.company_user = existing.company_user
      subject.role = existing.role

      expect(subject).not_to be_valid
      expect(subject.errors[:role_id]).to include('has already been assigned')
    end

    it 'allows same role for different company_users' do
      role = create(:role)
      company_user1 = create(:company_user, company: role.company)
      company_user2 = create(:company_user, company: role.company)

      create(:company_user_role, company_user: company_user1, role: role)

      subject.company_user = company_user2
      subject.role = role
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:company_user) }
    it { should belong_to(:role) }
  end
end
