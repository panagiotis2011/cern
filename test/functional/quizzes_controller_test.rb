require 'test_helper'

class QuizzesControllerTest < ActionController::TestCase
  setup do
    @quiz = quizzes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quizzes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quiz" do
    assert_difference('Quiz.count') do
      post :create, quiz: { ans1: @quiz.ans1, ans2: @quiz.ans2, ans3: @quiz.ans3, ans4: @quiz.ans4, correct: @quiz.correct, question: @quiz.question, title: @quiz.title, user_id: @quiz.user_id }
    end

    assert_redirected_to quiz_path(assigns(:quiz))
  end

  test "should show quiz" do
    get :show, id: @quiz
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quiz
    assert_response :success
  end

  test "should update quiz" do
    put :update, id: @quiz, quiz: { ans1: @quiz.ans1, ans2: @quiz.ans2, ans3: @quiz.ans3, ans4: @quiz.ans4, correct: @quiz.correct, question: @quiz.question, title: @quiz.title, user_id: @quiz.user_id }
    assert_redirected_to quiz_path(assigns(:quiz))
  end

  test "should destroy quiz" do
    assert_difference('Quiz.count', -1) do
      delete :destroy, id: @quiz
    end

    assert_redirected_to quizzes_path
  end
end
