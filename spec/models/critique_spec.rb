# frozen_string_literal: true

describe Critique do
  describe 'relations' do
    it { is_expected.to belong_to :target }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:approver).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :locale }

    context 'accepted' do
      subject { build :critique, :accepted }
      it { is_expected.to validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :critique, :rejected }
      it { is_expected.to validate_presence_of :approver }
    end
  end

  context 'scopes' do
    describe 'pending' do
      subject { Critique.pending }

      let!(:critique_1) { create :critique, :pending }
      let!(:critique_2) do
        create :critique, :accepted, user: build_stubbed(:user), approver: user
      end
      it { is_expected.to eq [review_1] }
    end

    describe 'visible' do
      subject { Critique.visible.order(:id) }
      let!(:critique_1) { create :critique, :pending }
      let!(:critique_2) do
        create :critique, :accepted, user: build_stubbed(:user), approver: user
      end
      let!(:critique_3) do
        create :critique, :rejected, user: build_stubbed(:user), approver: user
      end
      it { is_expected.to eq [review_1, review_2] }
    end
  end

  describe 'permissions' do
    let(:critique) { build_stubbed :critique }
    let(:user) { build_stubbed :user, :user, :week_registered }
    subject { Ability.new user }

    context 'review owner' do
      let(:critique) { build_stubbed :critique, user: user }

      context 'not banned' do
        it { is_expected.to be_able_to :read, review }
        it { is_expected.to be_able_to :new, review }
        it { is_expected.to be_able_to :create, review }
        it { is_expected.to be_able_to :edit, review }
        it { is_expected.to be_able_to :update, review }
        it { is_expected.to be_able_to :destroy, review }
        it { is_expected.to_not be_able_to :manage, review }
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }

        it { is_expected.to be_able_to :read, review }
        it { is_expected.to_not be_able_to :new, review }
        it { is_expected.to_not be_able_to :create, review }
        it { is_expected.to_not be_able_to :edit, review }
        it { is_expected.to_not be_able_to :update, review }
        it { is_expected.to_not be_able_to :destroy, review }
        it { is_expected.to_not be_able_to :manage, review }
      end

      context 'day registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }

        it { is_expected.to be_able_to :read, review }
        it { is_expected.to_not be_able_to :new, review }
        it { is_expected.to_not be_able_to :create, review }
        it { is_expected.to_not be_able_to :edit, review }
        it { is_expected.to_not be_able_to :update, review }
        it { is_expected.to_not be_able_to :destroy, review }
        it { is_expected.to_not be_able_to :manage, review }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned }

        it { is_expected.to be_able_to :read, review }
        it { is_expected.to_not be_able_to :new, review }
        it { is_expected.to_not be_able_to :create, review }
        it { is_expected.to_not be_able_to :edit, review }
        it { is_expected.to_not be_able_to :update, review }
        it { is_expected.to_not be_able_to :destroy, review }
        it { is_expected.to_not be_able_to :manage, review }
      end
    end

    context 'critique_moderator' do
      let(:user) { build_stubbed :user, :critique_moderator }
      it { is_expected.to be_able_to :manage, review }
    end

    context 'user' do
      it { is_expected.to be_able_to :read, review }
      it { is_expected.to_not be_able_to :new, review }
      it { is_expected.to_not be_able_to :edit, review }
      it { is_expected.to_not be_able_to :destroy, review }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to be_able_to :read, review }
      it { is_expected.to_not be_able_to :new, review }
      it { is_expected.to_not be_able_to :edit, review }
      it { is_expected.to_not be_able_to :destroy, review }
    end
  end

  it_behaves_like :antispam_concern, :critique
  it_behaves_like :topics_concern, :critique
  it_behaves_like :moderatable_concern, :critique
end
