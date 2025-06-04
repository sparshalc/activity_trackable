require 'rails_helper'

RSpec.describe Recognition, type: :model do
  let(:company) { create(:company, :with_settings) }
  let(:giver) { create(:user) }
  let(:recipient) { create(:user) }

  describe 'factory' do
    it 'has a valid factory' do
      recognition = create(:recognition, giver_user: giver, recipient_user: recipient)
      expect(recognition).to be_valid
    end

    it 'has valid trait factories' do
      expect(create(:recognition, :approved, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :rejected, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :teamwork, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :innovation, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :leadership, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :customer_service, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :going_above_beyond, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :high_points, giver_user: giver, recipient_user: recipient)).to be_valid
      expect(create(:recognition, :low_points, giver_user: giver, recipient_user: recipient)).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:recognition, giver_user: giver, recipient_user: recipient, company: company) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'category validation' do
      it 'is valid with valid categories' do
        Recognition::CATEGORIES.each do |category|
          subject.category = category
          expect(subject).to be_valid
        end
      end

      it 'is invalid with invalid category' do
        subject.category = 'invalid_category'
        expect(subject).not_to be_valid
        expect(subject.errors[:category]).to include('is not included in the list')
      end

      it 'requires category to be present' do
        subject.category = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:category]).to include("can't be blank")
      end
    end

    describe 'points validation' do
      it 'requires points to be present' do
        subject.points = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:points]).to include("can't be blank")
      end

      it 'requires points to be greater than 0' do
        subject.points = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:points]).to include('must be greater than 0')

        subject.points = -5
        expect(subject).not_to be_valid
        expect(subject.errors[:points]).to include('must be greater than 0')
      end

      it 'accepts positive points' do
        subject.points = 10
        expect(subject).to be_valid
      end
    end

    describe 'message validation' do
      it 'requires message to be present' do
        subject.message = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:message]).to include("can't be blank")

        subject.message = ''
        expect(subject).not_to be_valid
        expect(subject.errors[:message]).to include("can't be blank")
      end
    end

    describe 'recipient validation' do
      it 'requires recipient to be present' do
        subject.recipient = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:recipient]).to include("can't be blank")
      end
    end

    describe 'cannot_recognize_self validation' do
      it 'prevents self-recognition' do
        subject.recipient = subject.giver
        expect(subject).not_to be_valid
        expect(subject.errors[:recipient]).to include("can't recognize yourself")
      end

      it 'allows recognition of different users' do
        expect(subject.giver).not_to eq(subject.recipient)
        expect(subject).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:giver).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2) }

    it 'has correct default status' do
      recognition = create(:recognition, giver_user: giver, recipient_user: recipient)
      expect(recognition.status).to eq('pending')
    end
  end

  describe 'constants' do
    it 'defines CATEGORIES constant' do
      expect(Recognition::CATEGORIES).to match_array([
        "teamwork", "innovation", "leadership", "customer_service", "going_above_beyond"
      ])
    end
  end

  describe 'scopes' do
    let!(:old_recognition) { create(:recognition, giver_user: giver, recipient_user: recipient, created_at: 1.month.ago) }
    let!(:recent_recognition) { create(:recognition, giver_user: giver, recipient_user: recipient, created_at: 1.day.ago) }
    let!(:approved_recognition) { create(:recognition, :approved, giver_user: giver, recipient_user: recipient) }
    let!(:pending_recognition) { create(:recognition, giver_user: giver, recipient_user: recipient) }

    describe '.recent' do
      it 'orders by created_at desc' do
        # Reload to get fresh ordering
        recognitions = Recognition.recent.limit(2)
        expect(recognitions.first.created_at).to be > recognitions.last.created_at
      end
    end

    describe '.approved' do
      it 'returns only approved recognitions' do
        expect(Recognition.approved).to include(approved_recognition)
        expect(Recognition.approved).not_to include(pending_recognition)
      end
    end

    describe '.for_recipient' do
      let(:other_user) { create(:user) }
      let!(:other_recognition) { create(:recognition, giver_user: giver, recipient_user: other_user) }

      before { company.add_user(other_user) }

      it 'returns recognitions for specific recipient' do
        expect(Recognition.for_recipient(recipient.id)).to include(old_recognition, recent_recognition, approved_recognition, pending_recognition)
        expect(Recognition.for_recipient(recipient.id)).not_to include(other_recognition)
      end
    end

    describe '.for_giver' do
      let(:other_user) { create(:user) }
      let!(:other_recognition) { create(:recognition, giver_user: other_user, recipient_user: recipient) }

      before { company.add_user(other_user) }

      it 'returns recognitions from specific giver' do
        expect(Recognition.for_giver(giver.id)).to include(old_recognition, recent_recognition, approved_recognition, pending_recognition)
        expect(Recognition.for_giver(giver.id)).not_to include(other_recognition)
      end
    end
  end

  describe 'trait behaviors' do
    it 'approved trait sets status to approved' do
      recognition = create(:recognition, :approved, giver_user: giver, recipient_user: recipient)
      expect(recognition.status).to eq('approved')
    end

    it 'rejected trait sets status to rejected' do
      recognition = create(:recognition, :rejected, giver_user: giver, recipient_user: recipient)
      expect(recognition.status).to eq('rejected')
    end

    it 'category traits set appropriate category and message' do
      teamwork_recognition = create(:recognition, :teamwork, giver_user: giver, recipient_user: recipient)
      expect(teamwork_recognition.category).to eq('teamwork')
      expect(teamwork_recognition.message).to include('collaboration')

      innovation_recognition = create(:recognition, :innovation, giver_user: giver, recipient_user: recipient)
      expect(innovation_recognition.category).to eq('innovation')
      expect(innovation_recognition.message).to include('creative')
    end

    it 'points traits set appropriate points' do
      high_points_recognition = create(:recognition, :high_points, giver_user: giver, recipient_user: recipient)
      expect(high_points_recognition.points).to eq(20)

      low_points_recognition = create(:recognition, :low_points, giver_user: giver, recipient_user: recipient)
      expect(low_points_recognition.points).to eq(1)
    end
  end
end
