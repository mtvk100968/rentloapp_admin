// import 'package:flutter/material.dart';
//
// class RazorpayPaymentGatewayScreen extends StatefulWidget {
//   final int amount;
//   final Function(PaymentSuccessResponse) onPaymentSuccess; // ✅ Fix: Accepts function with response
//
//   RazorpayPaymentGatewayScreen({required this.amount, required this.onPaymentSuccess});
//
//   @override
//   _RazorpayPaymentGatewayScreenState createState() =>
//       _RazorpayPaymentGatewayScreenState();
// }
//
// class _RazorpayPaymentGatewayScreenState extends State<RazorpayPaymentGatewayScreen> {
//   late Razorpay _razorpay;
//   String selectedPaymentMethod = "UPI"; // Default payment method
//
//   final List<String> paymentOptions = [
//     "UPI",
//     "Credit/Debit Card",
//     "Net Banking",
//     "Wallets",
//     "Other"
//   ];
//
//   final Map<String, String> paymentIcons = {
//     "UPI": "assets/images/phonepe-icon.png",
//     "Credit/Debit Card": "assets/images/master-card-icon.png",
//     "Net Banking": "assets/images/master-card-icon.png",
//     "Wallets": "assets/images/visa-icon.png",
//     "Other": "assets/images/upi-icon.png",
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     Future.delayed(Duration(milliseconds: 500), _startPayment);
//   }
//
//   void _startPayment() {
//     var options = {
//       "key": "rzp_test_ABC123XYZ456", // 🔹 Replace with your Razorpay API Key
//       "amount": widget.amount, // Razorpay accepts amount in paise
//       "name": "Inyty Gift Vouchers",
//       "description": "Purchase Gift Voucher",
//       "prefill": {
//         "contact": "9876543210", // Replace with user’s phone number
//         "email": "user@example.com", // Replace with user’s email
//       },
//       "theme": {"color": "#A52A2A"}, // Brown Theme
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print("Error in Payment: $e");
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Successful! 🎉 Transaction ID: ${response.paymentId}")),
//     );
//     widget.onPaymentSuccess(response); // ✅ Navigate to CreateInvitationScreen
//     Navigator.pop(context); // ✅ Close payment screen after success
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Failed ❌ Error: ${response.message}")),
//     );
//     Navigator.pop(context); // ✅ Close payment screen after failure
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Selected Wallet: ${response.walletName}")),
//     );
//     Navigator.pop(context); // ✅ Close payment screen
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFD2B48C), // ✅ Matches HomeScreen color
//       appBar: AppBar(title: Text("Payment Options")),
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             color: Colors.green.shade100,
//             child: Text(
//               "Your gift amount: ₹${widget.amount}",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: paymentOptions.length,
//               itemBuilder: (context, index) {
//                 String option = paymentOptions[index];
//                 return ListTile(
//                   leading: Image.asset(paymentIcons[option] ?? "assets/icons/other.png", width: 40),
//                   title: Text(option),
//                   trailing: Radio(
//                     value: option,
//                     groupValue: selectedPaymentMethod,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedPaymentMethod = value.toString();
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: ElevatedButton(
//               onPressed: _startPayment,
//               child: Text("Proceed to Pay ₹${widget.amount}"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }