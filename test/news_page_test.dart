import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tdd_project/article.dart';
import 'package:tdd_project/main.dart';
import 'package:tdd_project/news_change_notifier.dart';
import 'package:tdd_project/news_page.dart';
import 'package:tdd_project/news_service.dart';

// widget test (test single widget) it is quick to test
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
    when(() => mockNewsService.getArticles()).thenAnswer(
        (_) async {
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

  testWidgets("title is displayed", (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    // to create widget
    await tester.pumpWidget(createWidgetUnderTest());
    // search for Text widget with text 'News'
    expect(find.text('News'), findsOneWidget);
  });

  testWidgets("loading indicator is displayed while waiting for articles", (WidgetTester tester) async {
    arrangeNewsServiceReturns3ArticlesAfter2SecondWait();
    // to create widget
    await tester.pumpWidget(createWidgetUnderTest());
    // to wait to run arrangeNewsServiceReturns3ArticlesAfter2SecondWait first then check the widget if exist
    await tester.pump(const Duration(milliseconds: 500));
    // search for CircularProgressIndicator widget
    expect(find.byKey(Key('progress-indicator')), findsOneWidget);
    // to complete test if CircularProgressIndicator widget is disappeared
    await tester.pumpAndSettle();
  });

  testWidgets("articles are displayed", (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    for(final article in articlesFromService) {
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
  });
}
