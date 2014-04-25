require 'spec_helper'

describe Moderation::AnimeVideoReportsController do
  before { sign_in moderator }

  let(:user) { create :user }
  let(:moderator) { create :user, id: User::Blackchestnut_ID }
  let(:anime_video) { create :anime_video, anime: create(:anime) }
  let!(:anime_video_report) { create :anime_video_report, user: user, kind: kind, anime_video: anime_video }

  describe :index do
    before { get :index }
    let(:kind) { 'broken' }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :accept do
    before { get :accept, id: anime_video_report.id }

    context :broken do
      let(:kind) { 'broken' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.state.should eq kind }
    end

    context :wrong do
      let(:kind) { 'wrong' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.state.should eq kind }
    end
  end

  describe :cancel do
    let(:anime_video) { create :anime_video, anime: create(:anime), state: kind }
    let!(:anime_video_report) { create :anime_video_report, user: user, kind: kind, anime_video: anime_video, state: 'accepted' }

    before { get :cancel, id: anime_video_report.id }

    context :broken do
      let(:kind) { 'broken' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.should be_working }
    end

    context :wrong do
      let(:kind) { 'wrong' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.should be_working }
    end
  end

  describe :reject do
    before { get :reject, id: anime_video_report.id }

    context :broken do
      let(:kind) { 'broken' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.state.should eq 'working' }
    end

    context :wrong do
      let(:kind) { 'wrong' }
      it { should redirect_to moderation_anime_video_reports_url }
      specify { anime_video.reload.state.should eq 'working' }
    end
  end
end
