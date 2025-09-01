# **SKRAMBL** 🛰️  
*A stealth layer for your SOL.*

SKRAMBL is a **privacy-first Solana wallet** that routes transactions through the **Oridion protocol** before they reach their destination — making it significantly harder to trace fund origins.  

Unlike traditional mixers, SKRAMBL doesn’t just shuffle funds. It leverages **planetary hops** and **delayed pods** to break transaction history patterns — while remaining **non-custodial**, **transparent**, and **user-controlled**.  

---

## 🚀 **How It Works**

1. **Generate a Pod**  
   - Choose the **amount**, **destination wallet**, and an optional **delay**.  
   - SKRAMBL builds a **Pod account** on-chain using your **Seed Vault**-secured key.  
   - The Pod acts as a stealth package, holding delivery details until release.  

2. **Scramble Through Oridion**  
   - SOL is routed through randomized **planet hops**.  
   - Delays and hop sequences make blockchain analysis extremely difficult.  
   - Optional on-chain **memos** let you track Pods without exposing recipient info.  

3. **Deliver to Destination**  
   - When the Pod completes its route, funds are **automatically released**.  
   - The Pod account is **closed** on-chain, leaving no active link to the source.  

---

## 🔍 **Transaction Flow**
Each hop and delay adds uncertainty, breaking direct traceability between sender and recipient.  

---

## 🛡️ **Privacy Features**
- **No direct source → destination link**  
- **Randomized routing** across planetary accounts  
- **Variable delays** to disrupt timing analysis  
- **Seed Vault integration** keeps keys secured on-device  
- **Flat fees** (not a % of transfer amount)  
- **Optional memos** for human-readable tracking  

---

## 📱 **App Features**
- **One-tap “Send SKRAMBLed”**  
  Simple form for destination, amount, and delay — SKRAMBL handles the rest.  

- **Real-time Transaction Status**  
  Clear phases in the UI:  
  1. **Sending** – Pod transaction created  
  2. **Confirming** – Solana finalization  
  3. **Scrambling** – Pod in transit through hops  
  4. **Delivering** – Pod finalizing delivery  
  5. **Completed** – funds delivered  

- **Burner Wallets**  
  Generate throwaway wallets directly in SKRAMBL for high-anonymity payments.  

---

## 🛠️ **Tech Stack**
- **Frontend**: Flutter (mobile-first, cross-platform)  
- **Wallet Security**: Solana Mobile Seed Vault SDK  
- **Blockchain**:  
  - Solana Mainnet via Helius RPC  
  - Oridion Anchor Program for Pod creation, routing, and delivery  
- **Backend**:  
  - AWS Lambda (Rust) + SQS for hop processing  
  - EventBridge for automation scheduling  

---

## 🧠 **How SKRAMBL Beats Blockchain Analysis**
Analysis tools exploit:  
1. **Direct linkages** (sender ↔ recipient in same tx)  
2. **Timing correlations** (matching send/receive timestamps)  
3. **Amount fingerprinting** (unique transfer sizes)  

**SKRAMBL neutralizes these:**  
- **Direct Link Breakage** – hops through unrelated PDAs sever sender-recipient ties.  
- **Timing Obfuscation** – delays randomize send/receive windows.  
- **Amount Mixing** – internal routing disrupts amount fingerprinting.  
- **Self-Destructing Pods** – Pod accounts close after delivery, leaving only historic traces.  
- **Non-Custodial** – all transactions are still **your signatures**; no third-party control.  

---

## ⚡ **Why SKRAMBL?**
- **Private** – breaks transaction linkability  
- **Secure** – destinations are immutable once created  
- **Low-cost** – flat fee, not percentage-based  
- **Non-custodial** – your keys, your funds  
- **Mobile-first** – designed for Solana Mobile / Seed Vault  

---

[![SKRAMBL Demo](https://img.youtube.com/vi/QREn8qQmtyU/0.jpg)](https://youtube.com/shorts/X5Mw2dXq76o)  

**Oridion Program ID**: `ord1qJZ3DB52s9NoG8nuoacW85aCyNvECa5kAqcBVBu`