// Example: using trompeloeil with Catch2 for mock-based testing.
//
// This file demonstrates how to define an interface, create a mock, and
// verify interactions. It is intentionally simple so that it serves as
// a starting point for new contributors.

#include <catch2/catch_test_macros.hpp>
#include <trompeloeil.hpp>

// Interface

class ICalculator {
 public:
  virtual ~ICalculator() = default;
  virtual int compute(int input) = 0;
};

// Mock

class MockCalculator : public ICalculator {
 public:
  MAKE_MOCK1(compute, int(int), override);
};

// Consumer under test

int double_compute(ICalculator& calc, int value) {
  return calc.compute(value) * 2;
}

// Tests

TEST_CASE("Mock verifies compute is called", "[mock]") {
  MockCalculator calc;

  REQUIRE_CALL(calc, compute(5)).RETURN(42);

  REQUIRE(double_compute(calc, 5) == 84);
}

TEST_CASE("Mock allows sequences of calls", "[mock]") {
  MockCalculator calc;

  trompeloeil::sequence seq;

  REQUIRE_CALL(calc, compute(1)).IN_SEQUENCE(seq).RETURN(10);
  REQUIRE_CALL(calc, compute(2)).IN_SEQUENCE(seq).RETURN(20);

  REQUIRE(double_compute(calc, 1) == 20);
  REQUIRE(double_compute(calc, 2) == 40);
}
