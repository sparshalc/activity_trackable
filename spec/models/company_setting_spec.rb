require 'rails_helper'

RSpec.describe CompanySetting, type: :model do
  describe 'associations' do
    it 'belongs to company' do
      setting = build(:company_setting)
      expect(setting.company).to be_present
    end
  end

  describe 'validations' do
    it 'validates numericality of activity_retention_days' do
      setting = build(:company_setting, activity_retention_days: 'invalid')
      expect(setting).not_to be_valid
      expect(setting.errors[:activity_retention_days]).to include('is not a number')
    end

    it 'allows activity_retention_days of 1' do
      setting = build(:company_setting, activity_retention_days: 1)
      expect(setting).to be_valid
    end

    it 'allows activity_retention_days of 365' do
      setting = build(:company_setting, activity_retention_days: 365)
      expect(setting).to be_valid
    end

    it 'does not allow activity_retention_days of 0' do
      setting = build(:company_setting, activity_retention_days: 0)
      expect(setting).not_to be_valid
      expect(setting.errors[:activity_retention_days]).to include('must be greater than or equal to 1')
    end

    it 'does not allow negative activity_retention_days' do
      setting = build(:company_setting, activity_retention_days: -5)
      expect(setting).not_to be_valid
      expect(setting.errors[:activity_retention_days]).to include('must be greater than or equal to 1')
    end
  end

  describe 'tenant behavior' do
    it 'includes acts_as_tenant functionality' do
      expect(CompanySetting.new).to respond_to(:company)
    end
  end

  describe 'default values' do
    let(:company) { create(:company) }

    it 'creates with default values through company' do
      company_setting = company.create_company_setting!(activity_retention_days: 2)
      expect(company_setting.activity_tracking).to be_nil
      expect(company_setting.activity_retention_days).to eq(2)
    end
  end

  describe 'factory traits' do
    it 'creates with activity disabled trait' do
      setting = create(:company_setting, :activity_disabled)
      expect(setting.activity_tracking).to be false
    end

    it 'creates with short retention trait' do
      setting = create(:company_setting, :short_retention)
      expect(setting.activity_retention_days).to eq(1)
    end

    it 'creates with long retention trait' do
      setting = create(:company_setting, :long_retention)
      expect(setting.activity_retention_days).to eq(365)
    end

    it 'creates with minimal retention trait' do
      setting = create(:company_setting, :minimal_retention)
      expect(setting.activity_retention_days).to eq(1)
    end

    it 'creates with extended retention trait' do
      setting = create(:company_setting, :extended_retention)
      expect(setting.activity_retention_days).to eq(90)
    end
  end

  describe 'activity_tracking field' do
    it 'allows true value' do
      setting = build(:company_setting, activity_tracking: true)
      expect(setting).to be_valid
      expect(setting.activity_tracking).to be true
    end

    it 'allows false value' do
      setting = build(:company_setting, activity_tracking: false)
      expect(setting).to be_valid
      expect(setting.activity_tracking).to be false
    end

    it 'allows nil value' do
      setting = build(:company_setting, activity_tracking: nil)
      expect(setting).to be_valid
      expect(setting.activity_tracking).to be_nil
    end
  end

  describe 'database constraints' do
    let(:company) { create(:company) }

    it 'allows duplicate settings for different companies' do
      company1 = create(:company, name: 'Company 1')
      company2 = create(:company, name: 'Company 2')

      setting1 = create(:company_setting, company: company1, activity_retention_days: 30)
      setting2 = build(:company_setting, company: company2, activity_retention_days: 30)

      expect(setting2).to be_valid
    end
  end

  describe 'timestamps' do
    it 'sets created_at and updated_at on creation' do
      setting = create(:company_setting)
      expect(setting.created_at).to be_present
      expect(setting.updated_at).to be_present
    end

    it 'updates updated_at on changes' do
      setting = create(:company_setting, activity_retention_days: 30)
      original_updated_at = setting.updated_at

      sleep(0.01) # Ensure time difference
      setting.update!(activity_retention_days: 60)

      expect(setting.updated_at).to be > original_updated_at
    end
  end

  describe 'edge cases' do
    it 'handles very large retention days' do
      setting = build(:company_setting, activity_retention_days: 999_999)
      expect(setting).to be_valid
    end

    it 'handles decimal values by converting to integer' do
      setting = build(:company_setting, activity_retention_days: 30.9)
      setting.valid?
      expect(setting.activity_retention_days).to eq(30)
    end
  end

  describe 'integration with Company model' do
    let(:company) { create(:company) }

    it 'can be accessed through company association' do
      setting = create(:company_setting, company: company)
      expect(company.company_setting).to eq(setting)
    end

    it 'is configured for dependent destroy in Company model' do
      # Verify the association is set up with dependent: :destroy
      company_association = Company.reflect_on_association(:company_setting)
      expect(company_association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'company delegated methods' do
    let(:company) { create(:company) }
    let(:setting) { create(:company_setting, company: company, activity_tracking: true, activity_retention_days: 45) }

    before { setting } # Ensure setting is created

    it 'delegates activity_tracking to company' do
      expect(company.activity_tracking).to eq(setting.activity_tracking)
    end

    it 'delegates activity_tracking? to company' do
      expect(company.activity_tracking?).to eq(setting.activity_tracking)
    end

    it 'delegates activity_retention_days to company' do
      expect(company.activity_retention_days).to eq(setting.activity_retention_days)
    end
  end

  describe 'creation through company' do
    it 'creates default settings when company is created' do
      company = create(:company)
      expect(company.company_setting).to be_present
      expect(company.company_setting.activity_retention_days).to eq(2)
    end
  end

  describe 'model behavior' do
    it 'can be updated after creation' do
      setting = create(:company_setting, activity_tracking: false, activity_retention_days: 30)

      expect {
        setting.update!(activity_tracking: true, activity_retention_days: 90)
      }.not_to raise_error

      setting.reload
      expect(setting.activity_tracking).to be true
      expect(setting.activity_retention_days).to eq(90)
    end

    it 'prevents invalid updates' do
      setting = create(:company_setting, activity_retention_days: 30)

      expect {
        setting.update!(activity_retention_days: 0)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
