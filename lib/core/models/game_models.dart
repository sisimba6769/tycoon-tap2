import 'package:flutter/foundation.dart';

class BusinessData {
  final String id;
  final String icon;
  final String name;
  final double baseCost;
  final double baseIncome;
  final double cycleTime; // seconds
  int owned;
  int level; // 1,2,3,4
  bool hasManager;
  double progress; // 0..1
  bool isRunning;
  double taxDebt;
  bool isStopped;
  List<bool> upgrades; // [x2, x5, x10]

  BusinessData({
    required this.id,
    required this.icon,
    required this.name,
    required this.baseCost,
    required this.baseIncome,
    required this.cycleTime,
    this.owned = 0,
    this.level = 1,
    this.hasManager = false,
    this.progress = 0,
    this.isRunning = false,
    this.taxDebt = 0,
    this.isStopped = false,
    List<bool>? upgrades,
  }) : upgrades = upgrades ?? [false, false, false];

  double get cost => baseCost * (pow115(owned));
  double get managerCost => cost * 50;

  double pow115(int n) {
    double result = 1.0;
    for (int i = 0; i < n; i++) result *= 1.15;
    return result;
  }

  double get levelMultiplier {
    switch (level) {
      case 2: return 2.0;
      case 3: return 5.0;
      case 4: return 10.0;
      default: return 1.0;
    }
  }

  double upgradeMultiplier() {
    double m = 1.0;
    if (upgrades[0]) m *= 2;
    if (upgrades[1]) m *= 5;
    if (upgrades[2]) m *= 10;
    return m;
  }

  double income(double prestigeMultiplier, double newsMultiplier) {
    if (owned == 0) return 0;
    return baseIncome * owned * levelMultiplier * upgradeMultiplier() * prestigeMultiplier * newsMultiplier;
  }

  double upgradeCost(int tier) {
    return baseCost * (owned > 0 ? owned : 1) * (tier + 1) * (tier + 1);
  }

  Map<String, dynamic> toMap() => {
    'owned': owned, 'level': level, 'hasManager': hasManager,
    'taxDebt': taxDebt, 'isStopped': isStopped,
    'upgrades': upgrades,
  };

  void fromMap(Map map) {
    owned = map['owned'] ?? 0;
    level = map['level'] ?? 1;
    hasManager = map['hasManager'] ?? false;
    taxDebt = (map['taxDebt'] ?? 0).toDouble();
    isStopped = map['isStopped'] ?? false;
    final u = map['upgrades'];
    if (u != null) upgrades = List<bool>.from(u);
  }

  BusinessData copyWith() => BusinessData(
    id: id, icon: icon, name: name, baseCost: baseCost,
    baseIncome: baseIncome, cycleTime: cycleTime, owned: owned,
    level: level, hasManager: hasManager, progress: progress,
    isRunning: isRunning, taxDebt: taxDebt, isStopped: isStopped,
    upgrades: List.from(upgrades),
  );
}

class InvestmentData {
  final String id;
  final String name;
  final String description;
  final double cost;
  final double chance;
  final double multiplier;
  final int cooldown; // seconds
  final String risk;
  bool isOnCooldown;
  int cooldownRemaining;

  InvestmentData({
    required this.id, required this.name, required this.description,
    required this.cost, required this.chance, required this.multiplier,
    required this.cooldown, required this.risk,
    this.isOnCooldown = false, this.cooldownRemaining = 0,
  });
}

class StockData {
  final String ticker;
  final String companyName;
  double currentPrice;
  final double volatility;
  final double dividendYield;
  List<double> history;
  int ownedShares;
  double avgBuyPrice;

  StockData({
    required this.ticker, required this.companyName,
    required this.currentPrice, required this.volatility,
    required this.dividendYield, List<double>? history,
    this.ownedShares = 0, this.avgBuyPrice = 0,
  }) : history = history ?? [currentPrice];

  double get totalValue => ownedShares * currentPrice;
  double get profitLoss => ownedShares > 0 ? (currentPrice - avgBuyPrice) * ownedShares : 0;

  Map<String, dynamic> toMap() => {
    'ticker': ticker, 'currentPrice': currentPrice,
    'history': history, 'ownedShares': ownedShares, 'avgBuyPrice': avgBuyPrice,
  };
}

class NewsItem {
  final String text;
  final double multiplier;
  final int duration; // seconds
  final bool positive;

  NewsItem({required this.text, required this.multiplier, required this.duration, required this.positive});
}

class RivalData {
  final String name;
  double capital;

  RivalData({required this.name, required this.capital});
}
