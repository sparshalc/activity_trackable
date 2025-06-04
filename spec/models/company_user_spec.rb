require 'rails_helper'

RSpec.describe CompanyUser, type: :model do
  let(:company) { create(:company, :with_settings) }
  let(:user) { create(:user) }
  let(:role) { company.roles.find_by(name: 'employee') }

  subject { build(:company_user, user: user, company: company) }

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:company_user)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:company_user, :with_role)).to be_valid
      expect(build(:company_user, :with_admin_role)).to be_valid
      expect(build(:company_user, :recently_joined)).to be_valid
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      subject.roles << role
      subject.current_role = role
      subject.save!
      expect(subject).to be_valid
    end

    it 'requires unique user per company' do
      existing = create(:company_user)
      subject.user = existing.user
      subject.company = existing.company

      expect(subject).not_to be_valid
      expect(subject.errors[:user_id]).to include('is already in this company')
    end

    it 'allows same user in different companies' do
      user = create(:user)
      company1 = create(:company)
      company2 = create(:company)

      create(:company_user, user: user, company: company1)

      subject.user = user
      subject.company = company2
      expect(subject).to be_valid
    end

    it 'validates current_role must be assigned' do
      company = create(:company, :with_settings)
      user = create(:user)
      other_role = create(:role, company: company)

      company_user = build(:company_user, user: user, company: company, current_role: other_role)
      expect(company_user).not_to be_valid
      expect(company_user.errors[:current_role]).to include("must be one of the user's assigned roles")
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
    it { should belong_to(:current_role).class_name('Role').optional }
    it { should have_many(:company_user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:company_user_roles) }
  end

  describe 'callbacks' do
    let(:company) { create(:company, :with_settings) }
    let(:user) { create(:user) }

    describe 'before_validation' do
      it 'sets joined_at on create' do
        freeze_time do
          company_user = build(:company_user, user: user, company: company, joined_at: nil)
          company_user.valid?
          expect(company_user.joined_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'does not override existing joined_at' do
        time = 1.day.ago
        company_user = build(:company_user, user: user, company: company, joined_at: time)
        company_user.valid?
        expect(company_user.joined_at.to_i).to eq(time.to_i)
      end
    end
  end

  describe '#can?' do
    let(:company) { create(:company, :with_settings) }
    let(:user) { create(:user) }
    let(:company_user) { create(:company_user, user: user, company: company) }
    let(:admin_role) { company.roles.find_by(name: 'admin') }

    it 'delegates to current_role' do
      company_user.assign_role(admin_role)

      expect(company_user.can?(:users, :view)).to be true
    end

    it 'returns false when no current_role' do
      expect(company_user.can?(:users, :view)).to be false
    end
  end
end
