
import 'package:flutter/material.dart';

enum TransactionCategory {
  // Expenses
  groceries,
  dining,
  transport,
  utilities,
  housing,
  health,
  entertainment,
  clothing,
  education,
  personalCare,
  gifts,
  subscriptions,
  gambling,
  cash,
  other,

  // Income
  salary,
  refund,
  transfer,
  incomeOther;

  String get localizedName {
    // Ideally use l10n, but for now hardcoded english/fallback
    // We will update this when l10n is fully integrated or use context provided helper
    switch (this) {
      case TransactionCategory.groceries: return 'Groceries';
      case TransactionCategory.dining: return 'Dining';
      case TransactionCategory.transport: return 'Transport';
      case TransactionCategory.utilities: return 'Utilities';
      case TransactionCategory.housing: return 'Housing';
      case TransactionCategory.health: return 'Health';
      case TransactionCategory.entertainment: return 'Entertainment';
      case TransactionCategory.clothing: return 'Clothing';
      case TransactionCategory.education: return 'Education';
      case TransactionCategory.personalCare: return 'Personal Care';
      case TransactionCategory.gifts: return 'Gifts';
      case TransactionCategory.subscriptions: return 'Subscriptions';
      case TransactionCategory.gambling: return 'Gambling';
      case TransactionCategory.cash: return 'Cash Withdrawal';
      case TransactionCategory.other: return 'Other';
      case TransactionCategory.salary: return 'Salary';
      case TransactionCategory.refund: return 'Refund';
      case TransactionCategory.transfer: return 'Transfer';
      case TransactionCategory.incomeOther: return 'Other Income';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.groceries: return Icons.local_grocery_store;
      case TransactionCategory.dining: return Icons.restaurant;
      case TransactionCategory.transport: return Icons.directions_bus;
      case TransactionCategory.utilities: return Icons.lightbulb;
      case TransactionCategory.housing: return Icons.home;
      case TransactionCategory.health: return Icons.local_hospital;
      case TransactionCategory.entertainment: return Icons.movie;
      case TransactionCategory.clothing: return Icons.checkroom;
      case TransactionCategory.education: return Icons.school;
      case TransactionCategory.personalCare: return Icons.face;
      case TransactionCategory.gifts: return Icons.card_giftcard;
      case TransactionCategory.subscriptions: return Icons.subscriptions;
      case TransactionCategory.gambling: return Icons.casino;
      case TransactionCategory.cash: return Icons.money;
      case TransactionCategory.other: return Icons.more_horiz;
      case TransactionCategory.salary: return Icons.work;
      case TransactionCategory.refund: return Icons.replay;
      case TransactionCategory.transfer: return Icons.swap_horiz;
      case TransactionCategory.incomeOther: return Icons.attach_money;
    }
  }

  Color get color {
    // Material 3 colors or fixed palette?
    // Using simple colors for now.
    switch (this) {
      case TransactionCategory.groceries: return Colors.green;
      case TransactionCategory.dining: return Colors.orange;
      case TransactionCategory.transport: return Colors.blue;
      case TransactionCategory.utilities: return Colors.yellow;
      case TransactionCategory.housing: return Colors.brown;
      case TransactionCategory.health: return Colors.red;
      case TransactionCategory.entertainment: return Colors.purple;
      case TransactionCategory.clothing: return Colors.pink;
      case TransactionCategory.education: return Colors.teal;
      case TransactionCategory.personalCare: return Colors.cyan;
      case TransactionCategory.gifts: return Colors.indigo;
      case TransactionCategory.subscriptions: return Colors.deepPurple;
      case TransactionCategory.gambling: return Colors.redAccent;
      case TransactionCategory.cash: return Colors.grey;
      case TransactionCategory.other: return Colors.blueGrey;
      case TransactionCategory.salary: return Colors.greenAccent;
      case TransactionCategory.refund: return Colors.lightGreen;
      case TransactionCategory.transfer: return Colors.blueAccent;
      case TransactionCategory.incomeOther: return Colors.lime;
    }
  }

  bool get isExpense {
    switch (this) {
      case TransactionCategory.salary:
      case TransactionCategory.refund:
      case TransactionCategory.transfer: // Transfer might be neutral, but lets treat as income for inbound transfers? 
      // Or should transfer be split? Transfer is usually internal.
      // If it's internal transfer, it's expense on one acc, income on other.
      // If it's external income, it's income.
      case TransactionCategory.incomeOther:
        return false;
      default:
        return true;
    }
  }
}
