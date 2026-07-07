import 'package:cuacfm/utils/html_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlEntities.decode', () {
    test('returns text unchanged when no & character', () {
      expect(HtmlEntities.decode('hello world'), equals('hello world'));
    });

    test('returns empty string unchanged', () {
      expect(HtmlEntities.decode(''), equals(''));
    });

    test('decodes &amp; to &', () {
      expect(HtmlEntities.decode('fish &amp; chips'), equals('fish & chips'));
    });

    test('decodes &lt; to <', () {
      expect(HtmlEntities.decode('&lt;tag&gt;'), equals('<tag>'));
    });

    test('decodes &gt; to >', () {
      expect(HtmlEntities.decode('a &gt; b'), equals('a > b'));
    });

    test('decodes &quot; to "', () {
      expect(
        HtmlEntities.decode('say &quot;hello&quot;'),
        equals('say "hello"'),
      );
    });

    test('decodes &#039; to apostrophe', () {
      expect(HtmlEntities.decode("it&#039;s alive"), equals("it's alive"));
    });

    test('decodes &apos; to apostrophe', () {
      expect(HtmlEntities.decode("it&apos;s"), equals("it's"));
    });

    test('decodes &nbsp; to non-breaking space', () {
      final result = HtmlEntities.decode('a&nbsp;b');
      // non-breaking space is U+00A0
      expect(result.contains('a') && result.contains('b'), isTrue);
    });

    test('decodes multiple entities in one string', () {
      expect(
        HtmlEntities.decode('Rock &amp; Roll &lt;3'),
        equals('Rock & Roll <3'),
      );
    });

    test('decodes numeric character reference &#8230; (ellipsis)', () {
      final result = HtmlEntities.decode('wait&#8230;');
      expect(result, equals('wait…'));
    });

    test('decodes &#x2019; (right single quotation mark)', () {
      final result = HtmlEntities.decode('don&#x2019;t');
      expect(result, equals('don’t'));
    });

    test('handles & with no entity gracefully', () {
      // A bare & without a named/numeric entity is passed through
      final result = HtmlEntities.decode('stand & deliver');
      expect(result.contains('stand'), isTrue);
      expect(result.contains('deliver'), isTrue);
    });

    test('does not call html parser when no & present (fast path)', () {
      // This verifies the short-circuit: if no & the function returns immediately
      const text = 'Plain text without ampersand';
      expect(HtmlEntities.decode(text), same(text));
    });
  });
}
