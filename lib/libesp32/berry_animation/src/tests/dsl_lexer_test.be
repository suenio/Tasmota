# DSL Lexer Test Suite
# Tests for DSLLexer class
#
# Command to run test is:
#    ./berry -s -g -m lib/libesp32/berry_animation -e "import tasmota" lib/libesp32/berry_animation/tests/dsl_lexer_test.be

import animation
import animation_dsl
import string

# Test basic tokenization
def test_basic_tokenization()
  print("Testing basic DSL tokenization...")
  
  var dsl_source = "strip length 60\ncolor red = 0xFF0000\nrun demo"
  
  var lexer = animation_dsl.DSLLexer(dsl_source)
  var tokens = lexer.tokenize()
  
  # Should have: strip, length, 60, color, red, =, #FF0000, run, demo, EOF
  print("  Found " + str(size(tokens)) + " tokens")
  for i : 0..4
    if i < size(tokens)
      print("  Token " + str(i) + ": " + tokens[i].tostring())
    end
  end
  assert(size(tokens) >= 9, "Should have at least 9 tokens")
  
  # Check first few tokens
  assert(tokens[0].type == animation_dsl.Token.KEYWORD && tokens[0].value == "strip")
  # Note: "length" might be IDENTIFIER, not KEYWORD - that's OK for DSL properties
  assert(tokens[2].type == animation_dsl.Token.NUMBER && tokens[2].value == "60")
  
  # Check color tokens
  var found_color_keyword = false
  var found_color_value = false
  for token : tokens
    if token.type == animation_dsl.Token.KEYWORD && token.value == "color"
      found_color_keyword = true
    elif token.type == animation_dsl.Token.COLOR && token.value == "0xFF0000"
      found_color_value = true
    end
  end
  assert(found_color_keyword, "Should find 'color' keyword")
  assert(found_color_value, "Should find '0xFF0000' color value")
  
  # Should have no errors (lexer would have raised exception if there were errors)
  
  print("✓ Basic tokenization test passed")
  return true
end

# Test color tokenization
def test_color_tokenization()
  print("Testing color tokenization...")
  
  var color_tests = [
    ["0xFF0000", animation_dsl.Token.COLOR],
    ["red", animation_dsl.Token.COLOR],
    ["blue", animation_dsl.Token.COLOR],
    ["white", animation_dsl.Token.COLOR]  # transparent is a keyword, so use white instead
  ]
  
  for test : color_tests
    var color_value = test[0]
    var expected_type = test[1]
    
    var lexer = animation_dsl.DSLLexer("color test = " + color_value)
    var tokens = lexer.tokenize()
    
    var found_color = false
    for token : tokens
      if token.value == color_value && token.type == expected_type
        found_color = true
        break
      end
    end
    
    assert(found_color, "Should recognize '" + color_value + "' as color")
  end
  
  print("✓ Color tokenization test passed")
  return true
end

# Test numeric tokenization
def test_numeric_tokenization()
  print("Testing numeric tokenization...")
  
  var numeric_tests = [
    ["42", animation_dsl.Token.NUMBER],
    ["3.14", animation_dsl.Token.NUMBER],
    ["2s", animation_dsl.Token.TIME],
    ["500ms", animation_dsl.Token.TIME],
    ["1m", animation_dsl.Token.TIME],
    ["2h", animation_dsl.Token.TIME],
    ["50%", animation_dsl.Token.PERCENTAGE],
    ["2x", animation_dsl.Token.MULTIPLIER]
  ]
  
  for test : numeric_tests
    var value = test[0]
    var expected_type = test[1]
    
    var lexer = animation_dsl.DSLLexer("value = " + value)
    var tokens = lexer.tokenize()
    
    var found_numeric = false
    for token : tokens
      if token.value == value && token.type == expected_type
        found_numeric = true
        
        # Test numeric value extraction
        if token.is_numeric()
          var numeric_val = token.get_numeric_value()
          assert(numeric_val != nil, "Should extract numeric value from " + value)
        end
        
        # Test time conversion
        if token.type == animation_dsl.Token.TIME
          var time_ms = token.get_numeric_value()
          assert(time_ms != nil && time_ms > 0, "Should convert time to milliseconds")
        end
        
        # Test percentage conversion
        if token.type == animation_dsl.Token.PERCENTAGE
          var percent_255 = token.get_numeric_value()
          assert(percent_255 != nil && percent_255 >= 0 && percent_255 <= 255, "Should convert percentage to 0-255 range")
        end
        
        break
      end
    end
    
    assert(found_numeric, "Should recognize '" + value + "' as " + animation_dsl.Token.to_string(expected_type))
  end
  
  print("✓ Numeric tokenization test passed")
  return true
end

# Test keyword recognition
def test_keyword_recognition()
  print("Testing keyword recognition...")
  
  var keywords = [
    "strip", "color", "animation", "sequence", 
    "play", "for", "repeat", "if", "run"
  ]
  
  for keyword : keywords
    var lexer = animation_dsl.DSLLexer(keyword + " test")
    var tokens = lexer.tokenize()
    
    assert(size(tokens) >= 2, "Should have at least 2 tokens")
    assert(tokens[0].type == animation_dsl.Token.KEYWORD, "'" + keyword + "' should be recognized as keyword")
    assert(tokens[0].value == keyword, "Keyword value should match")
  end
  
  print("✓ Keyword recognition test passed")
  return true
end

# Test operators and delimiters
def test_operators_and_delimiters()
  print("Testing operators and delimiters...")
  
  var operator_tests = [
    ["=", animation_dsl.Token.ASSIGN],
    ["==", animation_dsl.Token.EQUAL],
    ["!=", animation_dsl.Token.NOT_EQUAL],
    ["<", animation_dsl.Token.LESS_THAN],
    ["<=", animation_dsl.Token.LESS_EQUAL],
    [">", animation_dsl.Token.GREATER_THAN],
    [">=", animation_dsl.Token.GREATER_EQUAL],
    ["&&", animation_dsl.Token.LOGICAL_AND],
    ["||", animation_dsl.Token.LOGICAL_OR],
    ["!", animation_dsl.Token.LOGICAL_NOT],
    ["+", animation_dsl.Token.PLUS],
    ["-", animation_dsl.Token.MINUS],
    ["*", animation_dsl.Token.MULTIPLY],
    ["/", animation_dsl.Token.DIVIDE],
    ["%", animation_dsl.Token.MODULO],
    ["^", animation_dsl.Token.POWER],
    ["(", animation_dsl.Token.LEFT_PAREN],
    [")", animation_dsl.Token.RIGHT_PAREN],
    ["{", animation_dsl.Token.LEFT_BRACE],
    ["}", animation_dsl.Token.RIGHT_BRACE],
    ["[", animation_dsl.Token.LEFT_BRACKET],
    ["]", animation_dsl.Token.RIGHT_BRACKET],
    [",", animation_dsl.Token.COMMA],
    [";", animation_dsl.Token.SEMICOLON],
    [":", animation_dsl.Token.COLON],
    [".", animation_dsl.Token.DOT],
    ["->", animation_dsl.Token.ARROW]
  ]
  
  for test : operator_tests
    var op = test[0]
    var expected_type = test[1]
    
    var lexer = animation_dsl.DSLLexer("a " + op + " b")
    var tokens = lexer.tokenize()
    
    var found_operator = false
    for token : tokens
      if token.value == op && token.type == expected_type
        found_operator = true
        break
      end
    end
    
    assert(found_operator, "Should recognize '" + op + "' as " + animation_dsl.Token.to_string(expected_type))
  end
  
  print("✓ Operators and delimiters test passed")
  return true
end

# Test string literals
def test_string_literals()
  print("Testing string literals...")
  
  var string_tests = [
    '"hello world"',
    "'single quotes'",
    '"escaped \\"quotes\\""'
  ]
  
  for str_test : string_tests
    var lexer = animation_dsl.DSLLexer("text = " + str_test)
    var tokens = lexer.tokenize()
    
    var found_string = false
    for token : tokens
      if token.type == animation_dsl.Token.STRING
        found_string = true
        break
      end
    end
    
    assert(found_string, "Should recognize string literal: " + str_test)
    # No errors check needed - lexer would have raised exception if there were errors
  end
  
  # Test unterminated string (should raise exception)
  try
    var lexer = animation_dsl.DSLLexer('text = "unterminated string')
    var tokens = lexer.tokenize()
    assert(false, "Unterminated string should raise exception")
  except "lexical_error" as e, msg
    # Expected - unterminated string should raise lexical_error
  end
  
  print("✓ String literals test passed")
  return true
end

# Test variable references
def test_variable_references()
  print("Testing variable references...")
  
  var var_tests = [
    "$variable",
    "$my_var",
    "$_private"
  ]
  
  for var_test : var_tests
    var lexer = animation_dsl.DSLLexer("value = " + var_test)
    var tokens = lexer.tokenize()
    
    var found_var_ref = false
    for token : tokens
      if token.type == animation_dsl.Token.VARIABLE_REF && token.value == var_test
        found_var_ref = true
        break
      end
    end
    
    assert(found_var_ref, "Should recognize variable reference: " + var_test)
  end
  
  # Test invalid variable references (should raise exceptions)
  var invalid_tests = ["$123", "$"]
  for invalid_test : invalid_tests
    try
      var lexer = animation_dsl.DSLLexer("value = " + invalid_test)
      var tokens = lexer.tokenize()
      assert(false, "Invalid variable reference should raise exception: " + invalid_test)
    except "lexical_error" as e, msg
      # Expected - invalid variable reference should raise lexical_error
    end
  end
  
  print("✓ Variable references test passed")
  return true
end

# Test comments
def test_comments()
  print("Testing comments...")
  
  var comment_tests = [
    "# This is a comment",
    "color red = 0xFF0000  # Inline comment"
  ]
  
  for comment_test : comment_tests
    var lexer = animation_dsl.DSLLexer(comment_test)
    var tokens = lexer.tokenize()
    
    var found_comment = false
    for token : tokens
      if token.type == animation_dsl.Token.COMMENT
        found_comment = true
        break
      end
    end
    
    assert(found_comment, "Should recognize comment in: " + comment_test)
  end
  
  print("✓ Comments test passed")
  return true
end

# Test complex DSL example
def test_complex_dsl()
  print("Testing complex DSL example...")
  
  var complex_dsl = "# LED Strip Configuration\n" +
    "strip length 60\n" +
    "strip brightness 80%\n" +
    "\n" +
    "# Color Definitions\n" +
    "color red = 0xFF0000\n" +
    "color orange = rgb(255, 128, 0)\n" +
    "color yellow = hsv(60, 100, 100)\n" +
    "\n" +
    "# Animation Definitions\n" +
    "animation fire_gradient = gradient(color=red)\n" +
    "animation fire_base = shift_left(source=fire_gradient, speed=200ms)\n" +
    "\n" +
    "# Variable Definitions\n" +
    "set cycle_time = 5s\n" +
    "set brightness_level = $global_brightness\n" +
    "\n" +
    "# Sequence Definition\n" +
    "sequence campfire {\n" +
    "  play fire_base for $cycle_time\n" +
    "  repeat forever\n" +
    "}\n" +
    "\n" +
    "# Execution\n" +
    "run campfire"
  
  var lexer = animation_dsl.DSLLexer(complex_dsl)
  var tokens = lexer.tokenize()
  
  assert(size(tokens) > 50, "Should have many tokens")
  
  # Count token types
  var token_counts = {}
  for token : tokens
    var type_name = animation_dsl.Token.to_string(token.type)
    if token_counts.contains(type_name)
      token_counts[type_name] += 1
    else
      token_counts[type_name] = 1
    end
  end
  
  # Should have various token types
  assert(token_counts.contains("KEYWORD"), "Should have keywords")
  assert(token_counts.contains("IDENTIFIER"), "Should have identifiers")
  assert(token_counts.contains("COLOR"), "Should have colors")
  assert(token_counts.contains("TIME"), "Should have time values")
  assert(token_counts.contains("PERCENTAGE"), "Should have percentages")
  assert(token_counts.contains("VARIABLE_REF"), "Should have variable references")
  
  print("✓ Complex DSL test passed")
  return true
end

# Test error handling
def test_error_handling()
  print("Testing error handling...")
  
  # Test invalid characters (should raise exception)
  try
    var lexer1 = animation_dsl.DSLLexer("color red = @invalid")
    var tokens1 = lexer1.tokenize()
    assert(false, "Invalid character should raise exception")
  except "lexical_error" as e, msg
    # Expected - invalid character should raise lexical_error
    assert(size(msg) > 0, "Should have error message")
  end
  
  # Test invalid hex color (should raise exception)
  try
    var lexer2 = animation_dsl.DSLLexer("color red = 0xGGGGGG")
    var tokens2 = lexer2.tokenize()
    assert(false, "Invalid hex color should raise exception")
  except "lexical_error" as e, msg
    # Expected - invalid hex color should raise lexical_error
    assert(size(msg) > 0, "Should have error message")
  end
  
  # Test unterminated string (should raise exception)
  try
    var lexer3 = animation_dsl.DSLLexer('text = "unterminated')
    var tokens3 = lexer3.tokenize()
    assert(false, "Unterminated string should raise exception")
  except "lexical_error" as e, msg
    # Expected - unterminated string should raise lexical_error
    assert(size(msg) > 0, "Should have error message")
    assert(string.find(msg, "Unterminated") >= 0, "Error message should mention unterminated string")
  end
  
  print("✓ Error handling test passed")
  return true
end

# Run all tests
def run_dsl_lexer_tests()
  print("=== DSL Lexer Test Suite ===")
  
  var tests = [
    test_basic_tokenization,
    test_color_tokenization,
    test_numeric_tokenization,
    test_keyword_recognition,
    test_operators_and_delimiters,
    test_string_literals,
    test_variable_references,
    test_comments,
    test_complex_dsl,
    test_error_handling
  ]
  
  var passed = 0
  var total = size(tests)
  
  for test_func : tests
    try
      if test_func()
        passed += 1
      else
        print("✗ Test failed")
      end
    except .. as error_type, error_message
      print("✗ Test crashed: " + str(error_type) + " - " + str(error_message))
    end
  end
  
  print("\n=== Results: " + str(passed) + "/" + str(total) + " tests passed ===")
  
  if passed == total
    print("🎉 All DSL lexer tests passed!")
    return true
  else
    print("❌ Some DSL lexer tests failed")
    raise "test_failed"
  end
end

# Auto-run tests when file is executed
run_dsl_lexer_tests()