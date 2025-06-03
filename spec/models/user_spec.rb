require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without an email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'is not valid with an invalid email format' do
      subject.email = 'invalid-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('is invalid')
    end

    it 'is not valid with a short password' do
      subject.password = '123'
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is not valid with duplicate email' do
      create(:user, email: 'test@example.com')
      subject.email = 'test@example.com'

      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('has already been taken')
    end

    it 'requires password confirmation to match' do
      subject.password_confirmation = 'different_password'
      expect(subject).not_to be_valid
      expect(subject.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes trackable' do
      expect(User.devise_modules).to include(:trackable)
    end
  end

  describe 'trackable fields' do
    let(:user) { create(:user) }

    it 'tracks sign in count' do
      expect(user).to respond_to(:sign_in_count)
      expect(user.sign_in_count).to eq(0)
    end

    it 'tracks current sign in at' do
      expect(user).to respond_to(:current_sign_in_at)
    end

    it 'tracks last sign in at' do
      expect(user).to respond_to(:last_sign_in_at)
    end

    it 'tracks current sign in ip' do
      expect(user).to respond_to(:current_sign_in_ip)
    end

    it 'tracks last sign in ip' do
      expect(user).to respond_to(:last_sign_in_ip)
    end

    context 'with tracking data' do
      let(:tracked_user) { create(:user, :with_tracking_data) }

      it 'has sign in count greater than zero' do
        expect(tracked_user.sign_in_count).to be > 0
      end

      it 'has current sign in timestamp' do
        expect(tracked_user.current_sign_in_at).to be_present
      end

      it 'has last sign in timestamp' do
        expect(tracked_user.last_sign_in_at).to be_present
      end

      it 'has IP addresses recorded' do
        expect(tracked_user.current_sign_in_ip).to be_present
        expect(tracked_user.last_sign_in_ip).to be_present
      end
    end
  end
end
