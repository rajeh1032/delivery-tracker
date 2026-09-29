import { DELIVERY_STATUS } from "./constants.js";

export const deliveriesDB = [
  {
    id: 1001,
    order_number: "ORD-1001",
    customer_name: "Ahmed Ali",
    phone: "55512345",
    address: "Salmiya, Block 4, Street 12",
    amount_due: 18.75,
    payment_method: "cash",
    status: DELIVERY_STATUS.PENDING,
    version: 1,
    recipient_name: null,
    failure_reason: null,
    note: null,
    proof_url: null,
    completed_at: null,
    failed_at: null
  },
  {
    id: 1002,
    order_number: "ORD-1002",
    customer_name: "Fatima Al-Zahra",
    phone: "55567890",
    address: "Hawally, Block 2, Street 5, Building 14",
    amount_due: 34.5,
    payment_method: "cash",
    status: DELIVERY_STATUS.PENDING,
    version: 1,
    recipient_name: null,
    failure_reason: null,
    note: null,
    proof_url: null,
    completed_at: null,
    failed_at: null
  },
  {
    id: 1003,
    order_number: "ORD-1003",
    customer_name: "Mohammad Khaled",
    phone: "55598765",
    address: "Kuwait City, Sharq, Block 1, Tower 3",
    amount_due: 12.0,
    payment_method: "cash",
    status: DELIVERY_STATUS.PENDING,
    version: 1,
    recipient_name: null,
    failure_reason: null,
    note: null,
    proof_url: null,
    completed_at: null,
    failed_at: null
  },
  {
    id: 1004,
    order_number: "ORD-1004",
    customer_name: "Sara Al-Otaibi",
    phone: "55543210",
    address: "Farwaniya, Block 3, Street 20",
    amount_due: 25.0,
    payment_method: "cash",
    status: DELIVERY_STATUS.PENDING,
    version: 1,
    recipient_name: null,
    failure_reason: null,
    note: null,
    proof_url: null,
    completed_at: null,
    failed_at: null
  }
];

export const idempotencyStore = new Map();
