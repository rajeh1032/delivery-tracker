import { DELIVERY_STATUS } from "./constants.js";

const customerNames = [
  "Omar Al-Rashid", "Hessa Al-Mutairi", "Faisal Al-Ajmi", "Dana Al-Shammari",
  "Khaled Al-Dosari", "Lulwa Al-Salem", "Salem Al-Qattan", "Aisha Al-Hamad",
  "Ali Al-Mansour", "Rania Al-Nasser", "Fahad Al-Bader", "Maha Al-Saleh",
  "Abdulrahman Al-Omar", "Zainab Al-Ali", "Tariq Al-Mubarak", "Noor Al-Hassan",
  "Hamad Al-Ibrahim", "Basma Al-Khaled", "Saad Al-Farhan", "Latifa Al-Abdullah",
  "أحمد عبد الرحمن", "فاطمة محمد علي", "عبد الله سالم", "مريم خالد",
  "يوسف حسن", "نورة عبد العزيز", "بدر محمد", "حصة إبراهيم",
  "عبد الرحمن محمد عبد الله", "دانة فيصل"
];
const areas = [
  "Salmiya", "Hawally", "Mishref", "Jabriya", "Fahaheel",
  "Farwaniya", "Al-Rawda", "Sabah Al-Salem", "Kuwait City", "Dasman"
];
const amounts = [7.5, 12.25, 18.75, 25, 34.5, 42.75, 9.95, 63, 105.5, 3.25];

export const testDeliverySeed = customerNames.map((customerName, index) => ({
  id: 1011 + index,
  order_number: `ORD-${1011 + index}`,
  customer_name: customerName,
  phone: String(55580000 + index),
  address: `${areas[index % areas.length]}, Block ${index % 9 + 1}, Street ${index + 10}, Building ${index % 12 + 1}`,
  amount_due: amounts[index % amounts.length],
  payment_method: "cash",
  status: DELIVERY_STATUS.PENDING,
  version: 1,
  recipient_name: null,
  failure_reason: null,
  note: null,
  proof_url: null,
  completed_at: null,
  failed_at: null
}));
