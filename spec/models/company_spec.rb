require 'rails_helper'

RSpec.describe Company, type: :model do
  describe '#add_user' do
    let(:company) { create(:company) }
    let(:user) { create(:user) }

    it 'adds a user with default employee role' do
      expect { company.add_user(user) }.to change { company.company_users.count }.by(1)

      company_user = company.company_users.find_by(user: user)
      expect(company_user).to be_present
      expect(company_user.current_role.name).to eq('employee')
    end

    it 'adds a user with specified role' do
      company.add_user(user, 'admin')

      company_user = company.company_users.find_by(user: user)
      expect(company_user.current_role.name).to eq('admin')
    end

    it 'falls back to employee role if specified role does not exist' do
      company.add_user(user, 'nonexistent_role')

      company_user = company.company_users.find_by(user: user)
      expect(company_user.current_role.name).to eq('employee')
    end

    it 'sets joined_at timestamp' do
      freeze_time do
        company.add_user(user)
        company_user = company.company_users.find_by(user: user)
        expect(company_user.joined_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#remove_user' do
    let(:company) { create(:company) }
    let(:user) { create(:user) }

    before do
      company.add_user(user)
    end

    it 'removes a user from the company' do
      expect { company.remove_user(user) }.to change { company.company_users.count }.by(-1)
      expect(company.company_users.find_by(user: user)).to be_nil
    end

    it 'returns nil if user is not in company' do
      other_user = create(:user)
      expect(company.remove_user(other_user)).to be_nil
    end
  end

  describe '#active_users_count' do
    let(:company) { create(:company) }

    it 'returns count of active users' do
      active_user = create(:user)
      discarded_user = create(:user, discarded_at: 1.hour.ago)

      company.add_user(active_user)
      company.add_user(discarded_user)

      expect(company.active_users_count).to eq(1)
    end
  end

  describe '#discarded_users_count' do
    let(:company) { create(:company) }

    it 'returns count of discarded users' do
      active_user = create(:user)
      discarded_user = create(:user, discarded_at: 1.hour.ago)

      company.add_user(active_user)
      company.add_user(discarded_user)

      expect(company.discarded_users_count).to eq(1)
    end
  end
end
