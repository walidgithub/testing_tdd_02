import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tdd_project/article.dart';
import 'package:tdd_project/article_page.dart';
import 'package:tdd_project/main.dart';
import 'package:tdd_project/news_change_notifier.dart';
import 'package:tdd_project/news_page.dart';
import 'package:tdd_project/news_service.dart';

// integration test (test all app or big part in the app) it is slow to test
// -------------------------------------

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets("""Tapping on the the first article except open the article page
  where the full article content is displayed""", (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    // to create widget
    await tester.pumpWidget(createWidgetUnderTest());
    // to wait for arrangeNewsServiceReturns3Articles to run first
    await tester.pump();
    // find text 'Test 1 content' after tap (click) on item of list
    await tester.tap(find.text('Test 1 content'));
    // to complete test
    await tester.pumpAndSettle();

    // test that NewsPage screen no longer found
    expect(find.byType(NewsPage), findsNothing);
    // test that ArticlePage screen displayed
    expect(find.byType(ArticlePage), findsOneWidget);

    // check that text on the the first article 'Test 1' displayed on screen ArticlePage
    expect(find.text('Test 1'), findsOneWidget);
    // check that text on the the first article 'Test 1 content' displayed on screen ArticlePage
    expect(find.text('Test 1 content'), findsOneWidget);
  });
}
