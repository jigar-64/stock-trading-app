/// The 10 stocks used throughout the app with realistic NSE starting prices.
///
/// All prices are stored in paise (integer minor units) to avoid
/// floating-point drift in financial calculations.
class StockConstants {
  StockConstants._();

  /// Starting prices in paise for each stock symbol.
  static const Map<String, int> startingPricesPaise = {
    'RELIANCE': 284535,   // ₹2,845.35
    'TCS': 392080,        // ₹3,920.80
    'INFY': 148625,       // ₹1,486.25
    'HDFCBANK': 163290,   // ₹1,632.90
    'ICICIBANK': 121475,  // ₹1,214.75
    'SBIN': 83150,        // ₹831.50
    'ITC': 46820,         // ₹468.20
    'LT': 346700,         // ₹3,467.00
    'BHARTIARTL': 168945, // ₹1,689.45
    'AXISBANK': 115530,   // ₹1,155.30
  };

  /// Ordered list of all available stock symbols.
  static const List<String> allSymbols = [
    'RELIANCE',
    'TCS',
    'INFY',
    'HDFCBANK',
    'ICICIBANK',
    'SBIN',
    'ITC',
    'LT',
    'BHARTIARTL',
    'AXISBANK',
  ];

  /// Default wallet balance: ₹1,00,000.00 (10,000,000 paise).
  static const int defaultWalletBalancePaise = 10000000;

  /// Human-readable company names for display purposes.
  static const Map<String, String> companyNames = {
    'RELIANCE': 'Reliance Industries',
    'TCS': 'Tata Consultancy',
    'INFY': 'Infosys',
    'HDFCBANK': 'HDFC Bank',
    'ICICIBANK': 'ICICI Bank',
    'SBIN': 'State Bank of India',
    'ITC': 'ITC Limited',
    'LT': 'Larsen & Toubro',
    'BHARTIARTL': 'Bharti Airtel',
    'AXISBANK': 'Axis Bank',
  };
}
