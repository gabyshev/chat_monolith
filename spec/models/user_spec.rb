require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create(:user, email: 'test@test.com') }
  let(:invalid_user) { build(:user, email: 'test@test.com') }

  it { should have_many(:conversations) }
  it 'should have unique email' do
    expect(invalid_user).to_not be_valid
  end
end
