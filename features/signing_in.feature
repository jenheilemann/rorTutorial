Feature: Signing in

  Scenario: Unsuccessful signin
    Given a user visits the 'sign in' page
    When he submits invalid signin information
    Then he should see an error message

  Scenario: Unsuccessful signin
    Given a user visits the 'sign in' page
    When he submits an empty signin form
    Then he should see an error message

  Scenario: Successful signin
    Given a user visits the 'sign in' page
      And the user has an account
    When the user submits valid signin information
    Then he should see his profile page
      And he should see a 'sign out' link