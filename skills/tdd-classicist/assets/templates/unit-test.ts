/**
 * Unit Test Template — tdd-classicist skill
 *
 * Tier: Unit
 * Placement: colocated with the module under test (sibling file)
 * Naming: <module-name>.test.ts
 *
 * Principles:
 * - One behavior per test
 * - Test name describes the contract being proven
 * - Assert state/output, not call sequences
 * - Prefer real collaborators; stubs only for IO/nondeterminism
 * - Follow Red-Green-Refactor: write this test FIRST, watch it FAIL
 */

import { describe, it, expect } from "vitest"; // or jest

// import { myFunction } from './my-module';

describe("MyModule", () => {
  // Group by capability or behavior, not by method name

  describe("when given valid input", () => {
    it("returns the expected result", () => {
      // Arrange — set up real objects, minimal stubs if needed
      const input = { /* ... */ };

      // Act — exercise the SUT
      // const result = myFunction(input);

      // Assert — state/output verification, contract-shaped
      // expect(result).toEqual(expectedOutput);
    });
  });

  describe("when given invalid input", () => {
    it("returns a structured error with a stable code", () => {
      // Arrange
      const badInput = { /* ... */ };

      // Act
      // const result = myFunction(badInput);

      // Assert — verify error contract, not implementation details
      // expect(result.error).toBe('VALIDATION_FAILED');
    });
  });

  // Edge cases: test the boundaries of the contract
  // Regression: one test per bug fix, at this tier if possible
});
