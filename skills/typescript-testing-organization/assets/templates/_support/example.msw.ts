/**
 * MSW Handler Template
 *
 * Placement: test/_support/msw/<provider>.msw.ts
 *
 * Principles:
 * - MSW handlers are STUBS or FAKES, not expectation-driven mocks
 * - Return canned responses (stub) or maintain in-memory state (fake)
 * - Do NOT add expectation assertions unless the call sequence is
 *   explicitly part of the contract
 *
 * See: typescript-testing-organization/references/support-code.md
 * See: tdd-classicist/references/taxonomy-test-doubles.md (MSW section)
 */

// import { http, HttpResponse } from 'msw';

// export const paymentApiHandlers = [
//   // Stub: returns a canned successful response
//   http.post('https://api.payment.com/charges', async ({ request }) => {
//     const body = await request.json();
//
//     if (!body.currency || body.currency === 'invalid') {
//       return HttpResponse.json(
//         { error: { code: 'INVALID_CURRENCY', message: 'Invalid currency' } },
//         { status: 400 }
//       );
//     }
//
//     return HttpResponse.json(
//       {
//         charge_id: 'ch_fake_123',
//         status: 'succeeded',
//         amount: body.amount,
//         currency: body.currency,
//       },
//       { status: 201 }
//     );
//   }),
// ];
