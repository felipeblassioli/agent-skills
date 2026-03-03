/**
 * Fake Template
 *
 * Placement: test/_support/fakes/<dependency>.fake.ts
 *
 * Principles:
 * - Implement the same interface as the production dependency
 * - Deterministic (no randomness, no live network)
 * - May maintain internal state (e.g., in-memory Map)
 * - Suitable for sharing across tests
 *
 * See: typescript-testing-organization/references/support-code.md
 * See: tdd-classicist/references/taxonomy-test-doubles.md (fake)
 */

// import { EmailService, Email } from '../../src/services/email-service';

// export class FakeEmailService implements EmailService {
//   private sent: Email[] = [];
//
//   async send(email: Email): Promise<void> {
//     this.sent.push(email);
//   }
//
//   // Test inspection methods (not part of the production interface)
//   getSentEmails(): ReadonlyArray<Email> {
//     return this.sent;
//   }
//
//   getLastSentEmail(): Email | undefined {
//     return this.sent.at(-1);
//   }
//
//   reset(): void {
//     this.sent = [];
//   }
// }
