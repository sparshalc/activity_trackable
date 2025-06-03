require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = User.new(password: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is not valid with an invalid email format' do
      user = User.new(
        email: 'invalid-email',
        password: 'password123'
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is not valid with a short password' do
      user = User.new(
        email: 'test@example.com',
        password: '123'
      )
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is not valid with duplicate email' do
      User.create!(
        email: 'test@example.com',
        password: 'password123'
      )

      duplicate_user = User.new(
        email: 'test@example.com',
        password: 'password123'
      )

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
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
    let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

    it 'tracks sign in count' do
      expect(user).to respond_to(:sign_in_count)
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
  end
end
