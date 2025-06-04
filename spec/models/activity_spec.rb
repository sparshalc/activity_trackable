require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:activity)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:activity, :login)).to be_valid
      expect(build(:activity, :logout)).to be_valid
      expect(build(:activity, :profile_update)).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:activity) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires an action' do
      subject.action = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:action]).to include("can't be blank")
    end

    it 'requires a valid action' do
      subject.action = 'invalid_action'
      expect(subject).not_to be_valid
      expect(subject.errors[:action]).to include('is not included in the list')
    end

    it 'accepts valid actions' do
      Activity::ACTIONS.values.each do |action|
        subject.action = action
        expect(subject).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:trackable) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let(:company) { create(:company, :with_settings) }
    let(:user) { create(:user) }
    let!(:recent_activity) { create(:activity, :recent, user: user, company: company) }
    let!(:old_activity) { create(:activity, :old, user: user, company: company) }
    let!(:login_activity) { create(:activity, :login, user: user, company: company) }

    describe '.recent' do
      it 'orders activities by occurred_at desc' do
        activities = Activity.recent
        expect(activities.first.occurred_at).to be > activities.last.occurred_at
      end
    end

    describe '.by_action' do
      it 'filters activities by action' do
        activities = Activity.by_action('login')
        expect(activities).to include(login_activity)
      end
    end

    describe '.by_user' do
      it 'filters activities by user_id' do
        activities = Activity.by_user(user.id)
        expect(activities.count).to eq(3)
        expect(activities).to include(recent_activity, old_activity, login_activity)
      end
    end

    describe '.in_date_range' do
      it 'filters activities within date range' do
        start_date = 2.days.ago
        end_date = Time.current
        activities = Activity.in_date_range(start_date, end_date)
        expect(activities).to include(recent_activity)
        expect(activities).not_to include(old_activity)
      end
    end

    describe '.activity_tracking' do
      before do
        company.company_setting.update!(activity_tracking: true)
      end
      it 'filters activities by company_id' do
        activities = Activity.count
        expect(activities).to eq(3)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets occurred_at if blank' do
        activity = build(:activity, occurred_at: nil)
        expect { activity.valid? }.to change { activity.occurred_at }.from(nil)
      end

      it 'does not override existing occurred_at' do
        time = 1.hour.ago
        activity = build(:activity, occurred_at: time)
        activity.valid?
        expect(activity.occurred_at.to_i).to eql(time.to_i)
      end
    end

    describe 'before_save' do
      let(:activity) { build(:activity, metadata: { password: 'secret', token: 'abc123', normal_key: 'value' }) }

      it 'sanitizes sensitive metadata' do
        activity.save!
        expect(activity.metadata).not_to have_key('password')
        expect(activity.metadata).not_to have_key('token')
        expect(activity.metadata).to have_key('normal_key')
      end

      it 'enriches metadata with tracking information' do
        freeze_time do
          activity.save!
          expect(activity.metadata['tracked_at']).to eq(Time.current.iso8601)
        end
      end
    end
  end

  describe '.track' do
    let(:company) { create(:company, :with_settings) }
    let(:user) { create(:user) }
    let(:trackable) { user }

    it 'does not create activity when tracking is disabled' do
      company.company_setting.update!(activity_tracking: false)

      expect {
        Activity.track(trackable: trackable, action: 'login', user: user, company: company)
      }.not_to change { Activity.count }
    end

    it 'handles errors gracefully' do
      allow(Activity).to receive(:create!).and_raise(StandardError.new('Test error'))

      result = Activity.track(trackable: trackable, action: 'login', user: user, company: company)
      expect(result).to be_nil
    end
  end

  describe '.track!' do
    let(:company) { create(:company, :with_settings) }
    let(:user) { create(:user) }

    it 'raises error when tracking fails' do
      company.company_setting.update!(activity_tracking: false)

      expect {
        Activity.track!(trackable: user, action: 'login', user: user, company: company)
      }.to raise_error('Failed to track activity')
    end
  end

  describe '#trackable_name' do
    let(:user) { create(:user, full_name: 'John Doe') }
    let(:company) { create(:company, name: 'Test Company') }
    let(:recognition) { create(:recognition, id: 123) }

    it 'returns user full_name for User trackable' do
      activity = build(:activity, trackable: user)
      expect(activity.trackable_name).to eq('John Doe')
    end

    it 'returns recognition identifier for Recognition trackable' do
      activity = build(:activity, trackable: recognition)
      expect(activity.trackable_name).to eq('Recognition #123')
    end

    it 'returns company name for Company trackable' do
      activity = build(:activity, trackable: company)
      expect(activity.trackable_name).to eq('Test Company')
    end

    it 'returns generic identifier for unknown trackable' do
      activity = build(:activity, trackable_type: 'UnknownType', trackable_id: 456)
      expect(activity.trackable_name).to eq('UnknownType #456')
    end
  end

  describe '#description' do
    let(:user) { create(:user, full_name: 'John Doe') }
    let(:company) { create(:company) }

    it 'returns login description' do
      activity = build(:activity, :login, user: user)
      expect(activity.description).to eq('John Doe logged in')
    end

    it 'returns logout description' do
      activity = build(:activity, :logout, user: user)
      expect(activity.description).to eq('John Doe logged out')
    end

    it 'returns profile update description' do
      activity = build(:activity, :profile_update, user: user)
      expect(activity.description).to eq('John Doe updated profile')
    end

    it 'returns role assignment description' do
      activity = build(:activity, action: 'role_assigned', user: user, metadata: { 'role_name' => 'admin' })
      expect(activity.description).to eq('admin role assigned to John Doe')
    end

    it 'returns user discarded description with discarded_by' do
      activity = build(:activity, :user_discarded, user: user, trackable: user)
      expect(activity.description).to include('Admin User discarded user John Doe')
    end

    it 'returns generic description for unknown actions' do
      activity = build(:activity, action: 'custom_action', user: user)
      expect(activity.description).to eq('John Doe performed custom action')
    end
  end

  describe 'constants' do
    it 'defines expected actions' do
      expected_actions = %w[
        login logout give_recognition receive_recognition profile_update
        company_joined company_left role_assigned role_removed role_switch
        user_discarded user_undiscarded admin_action
      ]

      expect(Activity::ACTIONS.values).to match_array(expected_actions)
    end
  end
end
