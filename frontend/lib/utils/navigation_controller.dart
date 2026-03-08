import 'package:flutter/material.dart';
import '../models/news_item.dart';

class NavigationController {
  static final NavigationController _instance = NavigationController._internal();
  
  factory NavigationController() => _instance;
  
  NavigationController._internal();
  
  VoidCallback? onReturnToHome;
  Function(NewsItem, {VoidCallback? onSentencePracticed})? onShowArticleDetails;
  
  void returnToHome() {
    if (onReturnToHome != null) {
      onReturnToHome!();
    }
  }
  
  void showArticleDetails(NewsItem article, {VoidCallback? onSentencePracticed}) {
    if (onShowArticleDetails != null) {
      onShowArticleDetails!(article, onSentencePracticed: onSentencePracticed);
    }
  }
}