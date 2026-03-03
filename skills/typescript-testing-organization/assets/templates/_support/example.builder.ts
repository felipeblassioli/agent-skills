/**
 * Builder Template
 *
 * Placement: test/_support/builders/<entity>.builder.ts
 *
 * Principles:
 * - Provide sensible defaults for all required fields
 * - Support composable overrides
 * - Do NOT call external services or infrastructure
 *
 * See: typescript-testing-organization/references/support-code.md
 */

// import { Order, OrderStatus } from '../../src/domain/order';

// interface OrderOverrides {
//   id?: string;
//   status?: OrderStatus;
//   items?: Array<{ sku: string; qty: number }>;
//   createdAt?: Date;
// }

// let counter = 0;

// export function buildOrder(overrides: OrderOverrides = {}): Order {
//   counter++;
//   return {
//     id: overrides.id ?? `order-${counter}`,
//     status: overrides.status ?? 'pending',
//     items: overrides.items ?? [{ sku: 'DEFAULT-SKU', qty: 1 }],
//     createdAt: overrides.createdAt ?? new Date('2026-01-01T00:00:00Z'),
//   };
// }
