Feature: Config
  Background:
    Given a file named "test.md" with:
    """
    This is a very important sentence. There is a sentence here too.

    """
    And a file named "test.py" with:
    """
    # There is always something to say. Very good! (e.g., this is good)

    """

  Scenario: MinAlertLevel = warning
    Given a file named ".txtlint" with:
    """
    MinAlertLevel = warning

    [*]
    BasedOnStyles = txtlint
    """
    When I run txtlint "test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:txtlint.Editorializing:Consider removing 'very'

    """
    And the exit status should be 0

  Scenario: MinAlertLevel = error
    Given a file named ".txtlint" with:
    """
    MinAlertLevel = error

    [*]
    BasedOnStyles = txtlint
    """
    When I run txtlint "test.md"
    Then the output should contain exactly:
    """

    """
    And the exit status should be 0

  Scenario: Ignore BasedOnStyle for formats it doesn't match
    Given a file named ".txtlint" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.py]
    BasedOnStyles = txtlint
    """
    When I run txtlint "test.md"
    Then the output should contain exactly:
    """

    """
    And the exit status should be 0

  Scenario: Specify BasedOnStyle on a per-syntax basis
    Given a file named ".txtlint" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = txtlint

    [*.py]
    BasedOnStyles = write-good
    """
    When I run txtlint "."
    Then the output should contain exactly:
    """
    test.md:1:11:txtlint.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Adverbs:'Very' - Adverbs can weaken meaning

    """
    And the exit status should be 0

  Scenario: Disable/enable checks on a per-syntax basis
    Given a file named "_txtlint" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = txtlint

    [*.py]
    BasedOnStyles = write-good
    write-good.Adverbs = NO
    txtlint.WeasalWords = YES
    """
    When I run txtlint "."
    Then the output should contain exactly:
    """
    test.md:1:11:txtlint.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'

    """
    And the exit status should be 0

  Scenario: Overwrite BasedOnStyle on a per-syntax basis
    Given a file named "_txtlint" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = txtlint

    [*.py]
    BasedOnStyles = write-good

    """
    When I run txtlint "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Adverbs:'Very' - Adverbs can weaken meaning

    """
    And the exit status should be 0

  Scenario: Load two base styles
    Given a file named "_txtlint" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = TheEconomist, write-good

    """
    When I run txtlint "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Adverbs:'Very' - Adverbs can weaken meaning
    test.py:1:49:TheEconomist.Punctuation:Use 'eg' instead of 'e.g.'.

    """
    And the exit status should be 0