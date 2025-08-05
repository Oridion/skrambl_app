# **SKRAMBL** 🛰️  
*A stealth layer for your SOL.*

SKRAMBL is a **privacy-first Solana wallet** that routes your transactions through the **Oridion protocol** before they reach their final destination — making it significantly harder to trace where your funds came from.

Unlike traditional mixers, SKRAMBL doesn’t just shuffle funds; it uses a chain of **planetary hops** and **delayed “pods”** to break transaction history patterns — while staying **non-custodial**, **transparent**, and **user-controlled**.

---

## 🚀 **How It Works**

1. **Generate a Pod**  
   - You choose the **amount**, **destination wallet**, and optional **delay**.  
   - SKRAMBL builds a **Pod account** on-chain using your **Seed Vault**-secured key.  
   - The Pod is your "stealth package" — holding your SOL until delivery.

2. **Scramble Through Oridion**  
   - Your Pod is routed through multiple **randomized planets**.  
   - Delays and hop sequences make blockchain analysis extremely difficult.  
   - Optional on-chain **memo tags** allow you to track your Pods while keeping recipient details private.

3. **Delivery to Destination**  
   - Once your Pod finishes its route, the funds are **automatically released** to your chosen wallet.  
   - The Pod account is **closed** on-chain, leaving no active link to the original source.

---

## 🔍 **Transaction Flow**
Each hop and delay introduces uncertainty, breaking direct traceability between the sender and recipient.

---

## 🛡️ **Privacy Features**

- **No direct source → destination link**  
- **Randomized routing** between planetary accounts  
- **Variable delay times** to break timing analysis  
- **Seed Vault integration** ensures private keys never leave your device  
- **Optional memos** for human-readable tracking without leaking critical metadata  

---

## 📱 **App Features**

- **One-tap “Send SKRAMBLed”**  
  Simple form for entering destination, amount, and delay — SKRAMBL handles the rest.

- **Real-time Transaction Status**  
  Live UI phases:  
  1. **Sending** – building and submitting your Pod transaction  
  2. **Confirming** – waiting for Solana network finalization  
  3. **Scrambling** – Pod is in transit through Oridion hops  
  4. **Completed** – funds delivered to destination  

- **Burner Wallet Support (coming soon)**  
  Create temporary wallets directly from SKRAMBL for high-anonymity payments.

- **Live Balance & Price Tracking**  
  WebSocket streams keep balances up to date in SOL and USD.

---

## 🛠️ **Tech Stack**

- **Frontend**: Flutter (cross-platform, mobile-first)  
- **Wallet Security**: Solana Mobile Seed Vault SDK  
- **Blockchain**:  
  - **Solana Mainnet** via Helius RPC  
  - **Oridion Anchor Program** for Pod creation, routing, and delivery  
- **Backend**:  
  - AWS Lambda + SQS orchestration for hop processing  
  - EventBridge for automation scheduling  

---

## 🧠 **How SKRAMBL Beats Blockchain Analysis**

Blockchain analysis tools rely on **three main weaknesses** in standard wallet transactions:  
1. **Direct Address Linkage** – The sender and recipient appear in the same transaction record.  
2. **Timing Correlation** – Observers can match send and receive events occurring within a short window.  
3. **Amount Fingerprinting** – Identical, unusual transfer amounts are easy to trace.  

**SKRAMBL neutralizes these weaknesses**:  
- **Direct Link Breakage**  
  Transactions are never direct. The Oridion protocol inserts **multiple hops** through unrelated PDAs before delivery.  

- **Timing Obfuscation**  
  Variable delays (seconds to hours) make it nearly impossible to match send/receive pairs by timestamp.  

- **Amount Mixing**  
  Hops may aggregate or split SOL amounts internally before re-delivery, preventing unique-amount matching.  

- **Account Self-Destruction**  
  The Pod account is **closed on delivery**, erasing its presence from active account listings and leaving only historic ledger traces — disconnected from future spending.  

- **Non-Custodial Design**  
  Even though routing is randomized, all hops are still **your signed transactions**, ensuring no third party can seize funds.  

---

## ⚡ **Why SKRAMBL?**

- **Private**: Breaks linkability without relying on third-party custody.  
- **Non-Custodial**: You remain in control — funds move only through your signed transactions.  
- **Optimized for Mobile**: Designed for Solana Mobile / Seed Vault integration.  

---

- **ORIDION Program ID**: `ord1qJZ3DB52s9NoG8nuoacW85aCyNvECa5kAqcBVBu`
