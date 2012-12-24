# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
describe RoomController do
  before do
    @user = User.new.tap{|x| x.save! }
    @room = Room.new(:title => 'title', :user => @user).tap{|x| x.save! }
  end

  share_examples_for '部屋を消せる'  do
    before { post :delete, :id => @room.id }
    describe "room" do
      subject { assigns[:room] }
      its(:deleted) { should be_true }
    end

    describe "response" do
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end
  end

  context "ログイン時" do
    before do
      user = User.new.tap{|x| x.save! }
      session[:current_user_id] = user.id
    end
    it_should_behave_like '部屋を消せる'

    describe "部屋作成" do
      it { expect {
          post :create, {:room => {:title => 'foo' }}
        }.to change { Room.all.size }.by(1)
      }
    end

    describe "privateな部屋作成" do
      before {
          post :create, {:room => {:title => 'foo private', :is_public => false }}
      }
      subject { Room.last }
      its(:is_public) { should be_false }
    end

    describe "publicな部屋作成" do
      before {
          post :create, {:room => {:title => 'foo', :is_public => true }}
      }
      subject { Room.last }
      its(:is_public) { should be_true }
    end

  end

  context "owner以外でログイン時" do
    before do
      session[:current_user_id] = @user.id
    end
    it_should_behave_like '部屋を消せる'
  end

  context "未ログイン時" do
    before { session[:current_user_id] = nil }

    describe "部屋作成" do
      before  { get :create }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "/configure" do
      before { post :configure, :id => @room.id }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "/deleteにPOST後" do
      before { post :delete, :id => @room.id }

      describe "room" do
        subject { Room.find @room.id }
        its(:deleted) { should be_false }
      end

      describe "response" do
        subject { response }
        it { should redirect_to(:controller => 'chat', :action => 'index') }
      end
    end
  end
end
