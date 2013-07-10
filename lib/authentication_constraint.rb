class AuthenticationConstraint
  def matches?(request)
    return false unless request.cookies['remember_token'].present?

    user = User.find_by_remember_token(request.cookies['remember_token'])
    user.present?
  end
end