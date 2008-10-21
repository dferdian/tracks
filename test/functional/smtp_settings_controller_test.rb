require 'test_helper'

class SmtpSettingsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:smtp_settings)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_smtp_setting
    assert_difference('SmtpSetting.count') do
      post :create, :smtp_setting => { }
    end

    assert_redirected_to smtp_setting_path(assigns(:smtp_setting))
  end

  def test_should_show_smtp_setting
    get :show, :id => smtp_settings(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => smtp_settings(:one).id
    assert_response :success
  end

  def test_should_update_smtp_setting
    put :update, :id => smtp_settings(:one).id, :smtp_setting => { }
    assert_redirected_to smtp_setting_path(assigns(:smtp_setting))
  end

  def test_should_destroy_smtp_setting
    assert_difference('SmtpSetting.count', -1) do
      delete :destroy, :id => smtp_settings(:one).id
    end

    assert_redirected_to smtp_settings_path
  end
end
