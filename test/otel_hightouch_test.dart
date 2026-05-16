// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_hightouch/otel_hightouch.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_hightouch-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('syncs.trigger records source + dest + diff rows', () async {
    await tracedHightouch<String>(
      operation: 'syncs.trigger',
      invoke: () async => const HightouchCallResult(
        value: 'ok',
        result: HightouchResult(
          workspaceId: 'ws_1',
          sourceSlug: 'snowflake',
          modelName: 'enriched_users',
          syncId: 'sync_1',
          destinationSlug: 'salesforce',
          syncRunId: 'run_1',
          syncMode: 'upsert',
          runStatus: 'success',
          queryRows: 1000000,
          addedRows: 250,
          changedRows: 4800,
          removedRows: 0,
          rejectedRows: 3,
          attemptCount: 1,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('hightouch syncs.trigger')!);
    expect(a['hightouch.source.slug'], 'snowflake');
    expect(a['hightouch.destination.slug'], 'salesforce');
    expect(a['hightouch.sync.mode'], 'upsert');
    expect(a['hightouch.query.rows'], 1000000);
    expect(a['hightouch.changed.rows'], 4800);
    expect(a['hightouch.rejected.rows'], 3);
  });

  test('failed run sets span error', () async {
    await tracedHightouch<String>(
      operation: 'runs.get',
      invoke: () async => const HightouchCallResult(
        value: 'ok',
        result: HightouchResult(
          runStatus: 'failed',
          attemptCount: 3,
        ),
      ),
    );
    expect(
      spans.findSpanByName('hightouch runs.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutHightouchInstrumentationAsync(() async {
      await tracedHightouch<String>(
        operation: 'syncs.list',
        invoke: () async => const HightouchCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('hightouch '), isEmpty);
  });
}
