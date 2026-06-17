import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_models.dart';

class GameState {
  double money;
  double totalEarned;
  double tapPower;
  int prestigeLevel;
  double prestigeMultiplier;
  double newsMultiplier;
  int newsTimeRemaining;
  String currentNewsText;
  int currentTab;
  List<BusinessData> businesses;
  List<InvestmentData> investments;
  List<StockData> stocks;
  List<RivalData> rivals;
  NewsItem? activeNews;
  double taxRate;
  double totalTaxDebt;
  bool adminUnlocked;

  GameState({
    this.money = 10,
    this.totalEarned = 10,
    this.tapPower = 1,
    this.prestigeLevel = 0,
    this.prestigeMultiplier = 1.0,
    this.newsMultiplier = 1.0,
    this.newsTimeRemaining = 0,
    this.currentNewsText = '📈 Рынок стабилен',
    this.currentTab = 0,
    List<BusinessData>? businesses,
    List<InvestmentData>? investments,
    List<StockData>? stocks,
    List<RivalData>? rivals,
    this.activeNews,
    this.taxRate = 0.25,
    this.totalTaxDebt = 0,
    this.adminUnlocked = false,
  })  : businesses = businesses ?? _defaultBusinesses(),
        investments = investments ?? _defaultInvestments(),
        stocks = stocks ?? _defaultStocks(),
        rivals = rivals ?? _defaultRivals();

  double get incomePerSecond {
    return businesses.fold(0.0, (sum, b) {
      if (b.owned == 0 || b.isStopped) return sum;
      return sum + b.income(prestigeMultiplier, newsMultiplier) / b.cycleTime;
    });
  }

  double get prestige1MRequirement => 1000000 * pow(5, prestigeLevel).toDouble();

  static List<BusinessData> _defaultBusinesses() => [
    BusinessData(id: 'lemonade', icon: '🍋', name: 'Ларёк с лимонадом', baseCost: 10, baseIncome: 1, cycleTime: 1),
    BusinessData(id: 'pizza', icon: '🍕', name: 'Пиццерия', baseCost: 120, baseIncome: 8, cycleTime: 3),
    BusinessData(id: 'coffee', icon: '☕', name: 'Кофейня', baseCost: 1300, baseIncome: 47, cycleTime: 6),
    BusinessData(id: 'market', icon: '🏪', name: 'Супермаркет', baseCost: 14000, baseIncome: 400, cycleTime: 12),
    BusinessData(id: 'hotel', icon: '🏨', name: 'Отель', baseCost: 200000, baseIncome: 5200, cycleTime: 24),
    BusinessData(id: 'factory', icon: '🏭', name: 'Завод', baseCost: 3000000, baseIncome: 90000, cycleTime: 48),
    BusinessData(id: 'power', icon: '⚡', name: 'Электростанция', baseCost: 50000000, baseIncome: 1500000, cycleTime: 96),
    BusinessData(id: 'bank', icon: '🏦', name: 'Банк', baseCost: 1000000000, baseIncome: 30000000, cycleTime: 192),
    BusinessData(id: 'oil', icon: '🛢️', name: 'Нефтяная компания', baseCost: 25000000000, baseIncome: 750000000, cycleTime: 384),
    BusinessData(id: 'ai', icon: '🤖', name: 'ИИ корпорация', baseCost: 500000000000, baseIncome: 15000000000, cycleTime: 768),
    BusinessData(id: 'space', icon: '🚀', name: 'Космическая компания', baseCost: 10000000000000, baseIncome: 300000000000, cycleTime: 1536),
    BusinessData(id: 'city', icon: '🌍', name: 'Мегаполис', baseCost: 200000000000000, baseIncome: 6000000000000, cycleTime: 3072),
  ];

  static List<InvestmentData> _defaultInvestments() => [
    InvestmentData(id: 'startup', name: 'Стартап', description: 'Рискованно, но перспективно', cost: 1000, chance: 0.6, multiplier: 3, cooldown: 30, risk: 'Medium'),
    InvestmentData(id: 'crypto', name: 'Криптовалюта', description: 'Очень высокий риск', cost: 5000, chance: 0.4, multiplier: 5, cooldown: 60, risk: 'High'),
    InvestmentData(id: 'junk_bonds', name: 'Мусорные облигации', description: 'Низкий риск, низкий доход', cost: 2000, chance: 0.75, multiplier: 1.5, cooldown: 20, risk: 'Low'),
    InvestmentData(id: 'venture', name: 'Венчурный фонд', description: 'Диверсифицированный риск', cost: 50000, chance: 0.55, multiplier: 4, cooldown: 120, risk: 'High'),
    InvestmentData(id: 'oil_well', name: 'Нефтяная скважина', description: 'Стабильный актив', cost: 500000, chance: 0.7, multiplier: 2, cooldown: 180, risk: 'Medium'),
    InvestmentData(id: 'pharma', name: 'Фармацевтика', description: 'Лекарства всегда нужны', cost: 2000000, chance: 0.65, multiplier: 2.5, cooldown: 240, risk: 'Medium'),
    InvestmentData(id: 'diamond', name: 'Алмазный рудник', description: 'Редкий актив', cost: 10000000, chance: 0.5, multiplier: 6, cooldown: 300, risk: 'High'),
    InvestmentData(id: 'quantum', name: 'Квантовый стартап', description: 'Будущее технологий', cost: 100000000, chance: 0.35, multiplier: 10, cooldown: 600, risk: 'Legendary'),
    InvestmentData(id: 'mars', name: 'Марсианская колония', description: 'Межпланетный масштаб', cost: 1000000000, chance: 0.25, multiplier: 20, cooldown: 1800, risk: 'Legendary'),
  ];

  static List<StockData> _defaultStocks() => [
    StockData(ticker: 'APPL', companyName: 'Apple Tech', currentPrice: 150, volatility: 0.03, dividendYield: 0.005),
    StockData(ticker: 'GGLF', companyName: 'Googleflex', currentPrice: 2800, volatility: 0.04, dividendYield: 0.002),
    StockData(ticker: 'TSVL', companyName: 'Tesla Vehicles', currentPrice: 900, volatility: 0.06, dividendYield: 0.0),
    StockData(ticker: 'AMZN', companyName: 'Amazonas', currentPrice: 3400, volatility: 0.03, dividendYield: 0.001),
    StockData(ticker: 'PHMC', companyName: 'PharmaCorp', currentPrice: 450, volatility: 0.05, dividendYield: 0.03),
    StockData(ticker: 'MGBK', companyName: 'MegaBank', currentPrice: 220, volatility: 0.02, dividendYield: 0.04),
    StockData(ticker: 'OILX', companyName: 'OilEx Corp', currentPrice: 85, volatility: 0.07, dividendYield: 0.025),
    StockData(ticker: 'SPCX', companyName: 'SpaceX Ventures', currentPrice: 5000, volatility: 0.08, dividendYield: 0.0),
    StockData(ticker: 'RBMD', companyName: 'RoboMed', currentPrice: 340, volatility: 0.06, dividendYield: 0.01),
    StockData(ticker: 'GRPW', companyName: 'GreenPower', currentPrice: 120, volatility: 0.04, dividendYield: 0.02),
    StockData(ticker: 'LUXC', companyName: 'LuxCarry', currentPrice: 780, volatility: 0.03, dividendYield: 0.015),
    StockData(ticker: 'GMVS', companyName: 'GameVerse', currentPrice: 65, volatility: 0.09, dividendYield: 0.0),
  ];

  static List<RivalData> _defaultRivals() => [
    RivalData(name: 'Иван Стартапов', capital: 5000),
    RivalData(name: 'Ольга Миллионова', capital: 150000),
    RivalData(name: 'Дядя Жора', capital: 8000000),
    RivalData(name: 'МегаКорп Inc.', capital: 500000000),
    RivalData(name: 'Джефф Богатов', capital: 50000000000),
    RivalData(name: 'СинтетикГрупп', capital: 500000000000),
    RivalData(name: 'Галактик Холдинг', capital: 5000000000000),
  ];
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _gameTimer;
  Timer? _saveTimer;
  Timer? _newsTimer;
  Timer? _stockTimer;
  Timer? _rivalTimer;
  Timer? _taxTimer;
  final Random _random = Random();
  final List<NewsItem> _allNews = [
    NewsItem(text: '📈 Экономический бум!', multiplier: 2.0, duration: 30, positive: true),
    NewsItem(text: '📉 Финансовый кризис!', multiplier: 0.5, duration: 20, positive: false),
    NewsItem(text: '🤖 ИИ революция!', multiplier: 1.8, duration: 25, positive: true),
    NewsItem(text: '🌱 Зелёная экономика', multiplier: 1.4, duration: 20, positive: true),
    NewsItem(text: '🚀 Космическая гонка', multiplier: 1.6, duration: 15, positive: true),
    NewsItem(text: '💹 Рекордный рост рынка', multiplier: 1.9, duration: 30, positive: true),
    NewsItem(text: '🏦 Банковский коллапс', multiplier: 0.6, duration: 20, positive: false),
    NewsItem(text: '⚡ Энергетический кризис', multiplier: 0.7, duration: 15, positive: false),
    NewsItem(text: '💊 Фармацевтический бум', multiplier: 1.5, duration: 20, positive: true),
    NewsItem(text: '🛢️ Нефть дорожает', multiplier: 1.3, duration: 25, positive: true),
    NewsItem(text: '🌍 Глобальная рецессия', multiplier: 0.4, duration: 30, positive: false),
    NewsItem(text: '💰 Налоговые льготы', multiplier: 1.7, duration: 20, positive: true),
  ];

  GameNotifier() : super(GameState()) {
    _loadGame();
    _startTimers();
  }

  void _startTimers() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), _gameTick);
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveGame());
    _newsTimer = Timer.periodic(const Duration(seconds: 45), (_) => _triggerRandomNews());
    _stockTimer = Timer.periodic(const Duration(seconds: 3), (_) => _updateStocks());
    _rivalTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updateRivals());
    _taxTimer = Timer.periodic(const Duration(hours: 1), (_) => _checkTaxes());
  }

  void _gameTick(Timer t) {
    final dt = 0.1; // 100ms
    final s = state;
    bool changed = false;

    // Update business cycles
    final businesses = s.businesses;
    double earned = 0;
    for (final b in businesses) {
      if (b.owned == 0 || b.isStopped) continue;
      if (!b.isRunning && b.hasManager) {
        b.isRunning = true;
        changed = true;
      }
      if (b.isRunning) {
        b.progress += dt / b.cycleTime;
        if (b.progress >= 1.0) {
          b.progress = 0;
          final inc = b.income(s.prestigeMultiplier, s.newsMultiplier);
          earned += inc;
          // Tax
          final tax = inc * s.taxRate;
          b.taxDebt += tax;
          if (!b.hasManager) {
            b.isRunning = false;
          }
          changed = true;
        }
      }
    }

    // Update news timer
    if (s.newsTimeRemaining > 0) {
      final newTime = s.newsTimeRemaining - 1;
      if (newTime <= 0) {
        state = GameState(
          money: s.money + earned,
          totalEarned: s.totalEarned + earned,
          tapPower: s.tapPower,
          prestigeLevel: s.prestigeLevel,
          prestigeMultiplier: s.prestigeMultiplier,
          newsMultiplier: 1.0,
          newsTimeRemaining: 0,
          currentNewsText: '📊 Рынок стабилен',
          currentTab: s.currentTab,
          businesses: businesses,
          investments: s.investments,
          stocks: s.stocks,
          rivals: s.rivals,
          taxRate: s.taxRate,
          totalTaxDebt: s.totalTaxDebt,
          adminUnlocked: s.adminUnlocked,
        );
        return;
      }
      // Throttle: only update state every ~10 ticks to avoid rebuild storm
      if (changed || earned > 0) {
        state = _copyWith(earned: earned, newsTimeRemaining: newTime);
      }
      return;
    }

    if (changed || earned > 0) {
      state = _copyWith(earned: earned);
    }
  }

  GameState _copyWith({double earned = 0, int? newsTimeRemaining}) {
    final s = state;
    return GameState(
      money: s.money + earned,
      totalEarned: s.totalEarned + earned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: newsTimeRemaining ?? s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void tap() {
    final s = state;
    final income = s.tapPower * s.prestigeMultiplier * s.newsMultiplier;
    state = _copyWith(earned: income);
  }

  void buyBusiness(int index) {
    final s = state;
    final b = s.businesses[index];
    final cost = b.cost;
    if (s.money < cost) return;
    b.owned++;
    state = GameState(
      money: s.money - cost,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void runBusiness(int index) {
    final s = state;
    final b = s.businesses[index];
    if (b.owned == 0 || b.isRunning || b.isStopped) return;
    b.isRunning = true;
    state = _copyWith();
  }

  void buyManager(int index) {
    final s = state;
    final b = s.businesses[index];
    final cost = b.managerCost;
    if (s.money < cost || b.owned == 0) return;
    b.hasManager = true;
    state = GameState(
      money: s.money - cost,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void buyUpgrade(int businessIndex, int upgradeIndex) {
    final s = state;
    final b = s.businesses[businessIndex];
    if (b.upgrades[upgradeIndex]) return;
    final cost = b.upgradeCost(upgradeIndex);
    if (s.money < cost) return;
    b.upgrades[upgradeIndex] = true;
    state = GameState(
      money: s.money - cost,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void upgradeBusiness(int index) {
    final s = state;
    final b = s.businesses[index];
    if (b.level >= 4) return;
    final cost = b.cost * 100 * b.level;
    if (s.money < cost) return;
    b.level++;
    state = GameState(
      money: s.money - cost,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void invest(int index) {
    final s = state;
    final inv = s.investments[index];
    if (s.money < inv.cost || inv.isOnCooldown) return;
    final success = _random.nextDouble() < inv.chance;
    double moneyDelta = -inv.cost;
    if (success) {
      moneyDelta += inv.cost * inv.multiplier;
    }
    inv.isOnCooldown = true;
    inv.cooldownRemaining = inv.cooldown;
    // Start cooldown
    Timer.periodic(const Duration(seconds: 1), (t) {
      inv.cooldownRemaining--;
      if (inv.cooldownRemaining <= 0) {
        inv.isOnCooldown = false;
        t.cancel();
      }
      // Force rebuild
      state = _copyWith();
    });
    state = GameState(
      money: s.money + moneyDelta,
      totalEarned: moneyDelta > 0 ? s.totalEarned + moneyDelta : s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void buyStock(String ticker, int qty) {
    final s = state;
    final stock = s.stocks.firstWhere((st) => st.ticker == ticker);
    final total = stock.currentPrice * qty;
    if (s.money < total) return;
    final prevQty = stock.ownedShares;
    final prevAvg = stock.avgBuyPrice;
    stock.avgBuyPrice = prevQty == 0
        ? stock.currentPrice
        : (prevAvg * prevQty + stock.currentPrice * qty) / (prevQty + qty);
    stock.ownedShares += qty;
    state = GameState(
      money: s.money - total,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void sellStock(String ticker, int qty) {
    final s = state;
    final stock = s.stocks.firstWhere((st) => st.ticker == ticker);
    if (stock.ownedShares < qty) return;
    final total = stock.currentPrice * qty;
    stock.ownedShares -= qty;
    if (stock.ownedShares == 0) stock.avgBuyPrice = 0;
    state = GameState(
      money: s.money + total,
      totalEarned: s.totalEarned + total,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void payTax(int businessIndex) {
    final s = state;
    final b = s.businesses[businessIndex];
    if (s.money < b.taxDebt) return;
    final debt = b.taxDebt;
    b.taxDebt = 0;
    b.isStopped = false;
    state = GameState(
      money: s.money - debt,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void payAllTaxes() {
    final s = state;
    double total = s.businesses.fold(0.0, (sum, b) => sum + b.taxDebt);
    if (s.money < total) return;
    for (final b in s.businesses) {
      b.taxDebt = 0;
      b.isStopped = false;
    }
    state = GameState(
      money: s.money - total,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: 0,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void prestige() {
    final s = state;
    if (s.money < s.prestige1MRequirement) return;
    final newLevel = s.prestigeLevel + 1;
    final newMultiplier = 1.0 + newLevel * 0.5;
    final freshBusinesses = GameState._defaultBusinesses();
    state = GameState(
      money: 10,
      totalEarned: 10,
      tapPower: 1,
      prestigeLevel: newLevel,
      prestigeMultiplier: newMultiplier,
      newsMultiplier: 1.0,
      newsTimeRemaining: 0,
      currentNewsText: '✨ Новое начало',
      currentTab: s.currentTab,
      businesses: freshBusinesses,
      investments: GameState._defaultInvestments(),
      stocks: s.stocks, // keep portfolio
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: 0,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void setTab(int tab) {
    state = _copyWith();
    // use a fresh copy with updated tab
    final s = state;
    state = GameState(
      money: s.money,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: tab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void _triggerRandomNews() {
    final news = _allNews[_random.nextInt(_allNews.length)];
    final s = state;
    state = GameState(
      money: s.money,
      totalEarned: s.totalEarned,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: news.multiplier,
      newsTimeRemaining: news.duration,
      currentNewsText: news.text,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void _updateStocks() {
    final s = state;
    for (final stock in s.stocks) {
      final change = 1.0 + (_random.nextDouble() * 2 - 1) * stock.volatility;
      stock.currentPrice = (stock.currentPrice * change).clamp(1, double.infinity);
      stock.history.add(stock.currentPrice);
      if (stock.history.length > 50) stock.history.removeAt(0);
      // Pay dividends
      if (stock.ownedShares > 0 && stock.dividendYield > 0) {
        final div = stock.ownedShares * stock.currentPrice * stock.dividendYield / 365;
        state = GameState(
          money: s.money + div,
          totalEarned: s.totalEarned + div,
          tapPower: s.tapPower,
          prestigeLevel: s.prestigeLevel,
          prestigeMultiplier: s.prestigeMultiplier,
          newsMultiplier: s.newsMultiplier,
          newsTimeRemaining: s.newsTimeRemaining,
          currentNewsText: s.currentNewsText,
          currentTab: s.currentTab,
          businesses: s.businesses,
          investments: s.investments,
          stocks: s.stocks,
          rivals: s.rivals,
          taxRate: s.taxRate,
          totalTaxDebt: s.totalTaxDebt,
          adminUnlocked: s.adminUnlocked,
        );
      }
    }
    state = _copyWith();
  }

  void _updateRivals() {
    final s = state;
    for (final r in s.rivals) {
      r.capital *= (1 + _random.nextDouble() * 0.02);
    }
    state = _copyWith();
  }

  void _checkTaxes() {
    final s = state;
    for (final b in s.businesses) {
      if (b.taxDebt > 0) {
        b.isStopped = true;
      }
    }
    state = _copyWith();
  }

  // Admin actions
  void adminAddMoney(double amount) {
    final s = state;
    state = GameState(
      money: s.money + amount,
      totalEarned: s.totalEarned + amount,
      tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel,
      prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier,
      newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText,
      currentTab: s.currentTab,
      businesses: s.businesses,
      investments: s.investments,
      stocks: s.stocks,
      rivals: s.rivals,
      taxRate: s.taxRate,
      totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: s.adminUnlocked,
    );
  }

  void adminAllManagers() {
    for (final b in state.businesses) {
      b.hasManager = true;
    }
    state = _copyWith();
  }

  void adminMaxBusinesses() {
    for (final b in state.businesses) {
      b.owned = 100;
      b.level = 4;
      for (int i = 0; i < 3; i++) b.upgrades[i] = true;
    }
    state = _copyWith();
  }

  void unlockAdmin() {
    final s = state;
    state = GameState(
      money: s.money, totalEarned: s.totalEarned, tapPower: s.tapPower,
      prestigeLevel: s.prestigeLevel, prestigeMultiplier: s.prestigeMultiplier,
      newsMultiplier: s.newsMultiplier, newsTimeRemaining: s.newsTimeRemaining,
      currentNewsText: s.currentNewsText, currentTab: s.currentTab,
      businesses: s.businesses, investments: s.investments, stocks: s.stocks,
      rivals: s.rivals, taxRate: s.taxRate, totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: true,
    );
  }

  void resetGame() {
    final s = state;
    state = GameState(adminUnlocked: s.adminUnlocked);
    _saveGame();
  }

  void _saveGame() {
    final s = state;
    final box = Hive.box('game');
    box.put('money', s.money);
    box.put('totalEarned', s.totalEarned);
    box.put('tapPower', s.tapPower);
    box.put('prestigeLevel', s.prestigeLevel);
    box.put('newsMultiplier', s.newsMultiplier);
    box.put('newsTimeRemaining', s.newsTimeRemaining);
    box.put('currentNewsText', s.currentNewsText);
    final bizMaps = s.businesses.map((b) => b.toMap()).toList();
    box.put('businesses', bizMaps);
    final stockMaps = s.stocks.map((st) => {
      'ticker': st.ticker, 'currentPrice': st.currentPrice,
      'history': st.history, 'ownedShares': st.ownedShares, 'avgBuyPrice': st.avgBuyPrice,
    }).toList();
    box.put('stocks', stockMaps);
    box.put('adminUnlocked', s.adminUnlocked);
  }

  void _loadGame() {
    final box = Hive.box('game');
    if (!box.containsKey('money')) return;
    final s = state;
    final money = (box.get('money') as num?)?.toDouble() ?? 10;
    final totalEarned = (box.get('totalEarned') as num?)?.toDouble() ?? 10;
    final tapPower = (box.get('tapPower') as num?)?.toDouble() ?? 1;
    final prestigeLevel = (box.get('prestigeLevel') as int?) ?? 0;
    final prestigeMultiplier = 1.0 + prestigeLevel * 0.5;
    final newsMultiplier = (box.get('newsMultiplier') as num?)?.toDouble() ?? 1.0;
    final newsTime = (box.get('newsTimeRemaining') as int?) ?? 0;
    final newsText = (box.get('currentNewsText') as String?) ?? '📊 Рынок стабилен';
    final adminUnlocked = (box.get('adminUnlocked') as bool?) ?? false;

    final savedBiz = box.get('businesses') as List?;
    final businesses = s.businesses;
    if (savedBiz != null) {
      for (int i = 0; i < businesses.length && i < savedBiz.length; i++) {
        businesses[i].fromMap(Map.from(savedBiz[i] as Map));
      }
    }

    final savedStocks = box.get('stocks') as List?;
    final stocks = s.stocks;
    if (savedStocks != null) {
      for (int i = 0; i < stocks.length && i < savedStocks.length; i++) {
        final m = Map.from(savedStocks[i] as Map);
        stocks[i].currentPrice = (m['currentPrice'] as num?)?.toDouble() ?? stocks[i].currentPrice;
        stocks[i].ownedShares = (m['ownedShares'] as int?) ?? 0;
        stocks[i].avgBuyPrice = (m['avgBuyPrice'] as num?)?.toDouble() ?? 0;
        final h = m['history'] as List?;
        if (h != null) stocks[i].history = h.map((e) => (e as num).toDouble()).toList();
      }
    }

    state = GameState(
      money: money, totalEarned: totalEarned, tapPower: tapPower,
      prestigeLevel: prestigeLevel, prestigeMultiplier: prestigeMultiplier,
      newsMultiplier: newsMultiplier, newsTimeRemaining: newsTime,
      currentNewsText: newsText, businesses: businesses, stocks: stocks,
      rivals: s.rivals, investments: s.investments,
      taxRate: s.taxRate, totalTaxDebt: s.totalTaxDebt,
      adminUnlocked: adminUnlocked,
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _saveTimer?.cancel();
    _newsTimer?.cancel();
    _stockTimer?.cancel();
    _rivalTimer?.cancel();
    _taxTimer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
