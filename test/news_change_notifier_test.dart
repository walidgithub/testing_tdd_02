import 'package:tdd_project/article.dart';
import 'package:tdd_project/news_change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_project/news_service.dart';
import 'package:mocktail/mocktail.dart';

// unit test (test method or class) it is quick to test
// -------------------------------------

// create mock test manually and not efficient
// class BadMockNewsService implements NewsService {
//   bool getArticlesCalled = false;
//
//   @override
//   Future<List<Article>> getArticles() async {
//     getArticlesCalled = true;
//     return [
//       Article(title: 'test 1', content: 'test 1 content'),
//       Article(title: 'test 2', content: 'test 2 content'),
//       Article(title: 'test 3', content: 'test 3 content'),
//     ];
//   }
// }

// create mock test by package
class MockNewsService extends Mock implements NewsService {}

void main() {
  // sut means >> system under test
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  // setup method will first run
  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  // we will edit mock functionality
  // test if initial values [that in the class] are correct
  test("initial values are correct", () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('getArticles', () {
    final articlesFromService =
    [
      Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content'),
    ];

    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles()).thenAnswer((_) async => articlesFromService);
    }

    test("gets articles using NewsService", () async {
      arrangeNewsServiceReturns3Articles();
      await sut.getArticles();
      // verify if getArticles function is called from (NewsService) if not so test would fail
      verify(() => mockNewsService.getArticles()).called(1);
    });

    test("""indicates loading of data,
        sets articles to the ones from the service,
        indicates that data is not being loaded anymore""", () async {
      arrangeNewsServiceReturns3Articles();
      final future = sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.articles, articlesFromService
      );
      expect(sut.isLoading, false);
    });
  });
}

// 44.15 minute
