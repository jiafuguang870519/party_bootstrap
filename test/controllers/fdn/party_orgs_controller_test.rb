require 'test_helper'

class Fdn::PartyOrgsControllerTest < ActionController::TestCase
  setup do
    @fdn_party_org = fdn_party_orgs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fdn_party_orgs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fdn_party_org" do
    assert_difference('Fdn::PartyOrg.count') do
      post :create, fdn_party_org: { activist_party_members: @fdn_party_org.activist_party_members, name: @fdn_party_org.name, parent_name: @fdn_party_org.parent_name, party_members: @fdn_party_org.party_members, pre_party_members: @fdn_party_org.pre_party_members, setting_date: @fdn_party_org.setting_date }
    end

    assert_redirected_to fdn_party_org_path(assigns(:fdn_party_org))
  end

  test "should show fdn_party_org" do
    get :show, id: @fdn_party_org
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fdn_party_org
    assert_response :success
  end

  test "should update fdn_party_org" do
    patch :update, id: @fdn_party_org, fdn_party_org: { activist_party_members: @fdn_party_org.activist_party_members, name: @fdn_party_org.name, parent_name: @fdn_party_org.parent_name, party_members: @fdn_party_org.party_members, pre_party_members: @fdn_party_org.pre_party_members, setting_date: @fdn_party_org.setting_date }
    assert_redirected_to fdn_party_org_path(assigns(:fdn_party_org))
  end

  test "should destroy fdn_party_org" do
    assert_difference('Fdn::PartyOrg.count', -1) do
      delete :destroy, id: @fdn_party_org
    end

    assert_redirected_to fdn_party_orgs_path
  end
end
