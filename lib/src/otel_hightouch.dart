// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_hightouch_suppression.dart';

const _tracerName = 'dartastic_otel_libs_hightouch';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class HightouchResult {
  const HightouchResult({
    this.workspaceId,
    this.sourceSlug,
    this.modelId,
    this.modelName,
    this.syncId,
    this.destinationSlug,
    this.syncRunId,
    this.syncMode,
    this.runStatus,
    this.queryRows,
    this.addedRows,
    this.changedRows,
    this.removedRows,
    this.rejectedRows,
    this.attemptCount,
    this.statusCode,
  });

  /// Hightouch workspace (tenant).
  final String? workspaceId;

  /// `snowflake` / `bigquery` / `databricks` / `redshift` / `postgres`
  /// / `s3` / `mongodb` — the warehouse/source the model reads from.
  final String? sourceSlug;

  final String? modelId;
  final String? modelName;
  final String? syncId;

  /// `salesforce` / `hubspot` / `marketo` / `iterable` / `intercom` /
  /// `slack` / `customer_io` / `airtable` / `s3` — where rows land.
  final String? destinationSlug;

  final String? syncRunId;

  /// `upsert` / `update` / `insert` / `mirror` — Hightouch's sync
  /// modes.
  final String? syncMode;

  /// `success` / `failed` / `cancelled` / `interrupted` /
  /// `pending` / `queued` / `processing` / `warning`.
  final String? runStatus;

  /// Rows the source query returned (before diffing).
  final int? queryRows;

  /// Diff results — only rows that changed actually get pushed
  /// downstream, so these are critical cost dims.
  final int? addedRows;
  final int? changedRows;
  final int? removedRows;

  /// Rows rejected by the destination (bad payload, validation, etc.)
  /// — these contribute to `warning` runs.
  final int? rejectedRows;

  /// Auto-retry attempt count.
  final int? attemptCount;

  final int? statusCode;
}

class HightouchCallResult<T> {
  const HightouchCallResult({required this.value, this.result});
  final T value;
  final HightouchResult? result;
}

/// Wraps a Hightouch API call in a CLIENT span. [operation] is one of
/// `syncs.list`, `syncs.get`, `syncs.trigger`, `syncs.create`,
/// `models.create`, `runs.list`, `runs.get`, `runs.cancel`,
/// `destinations.list`, `sources.list`, `events.send`.
Future<T> tracedHightouch<T>({
  required String operation,
  required Future<HightouchCallResult<T>> Function() invoke,
}) async {
  if (hightouchInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'hightouch',
    'rpc.method': operation,
    'hightouch.operation': operation,
  };

  final span = _tracer().startSpan(
    'hightouch $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.workspaceId != null) {
        extras.add(OTel.attributeString(
          'hightouch.workspace.id',
          r.result!.workspaceId!,
        ));
      }
      if (r.result!.sourceSlug != null) {
        extras.add(OTel.attributeString(
          'hightouch.source.slug',
          r.result!.sourceSlug!,
        ));
      }
      if (r.result!.modelId != null) {
        extras.add(OTel.attributeString(
          'hightouch.model.id',
          r.result!.modelId!,
        ));
      }
      if (r.result!.modelName != null) {
        extras.add(OTel.attributeString(
          'hightouch.model.name',
          r.result!.modelName!,
        ));
      }
      if (r.result!.syncId != null) {
        extras.add(OTel.attributeString(
          'hightouch.sync.id',
          r.result!.syncId!,
        ));
      }
      if (r.result!.destinationSlug != null) {
        extras.add(OTel.attributeString(
          'hightouch.destination.slug',
          r.result!.destinationSlug!,
        ));
      }
      if (r.result!.syncRunId != null) {
        extras.add(OTel.attributeString(
          'hightouch.sync_run.id',
          r.result!.syncRunId!,
        ));
      }
      if (r.result!.syncMode != null) {
        extras.add(OTel.attributeString(
          'hightouch.sync.mode',
          r.result!.syncMode!,
        ));
      }
      if (r.result!.runStatus != null) {
        extras.add(OTel.attributeString(
          'hightouch.run.status',
          r.result!.runStatus!,
        ));
        if (r.result!.runStatus == 'failed' ||
            r.result!.runStatus == 'interrupted') {
          span.setStatus(
            SpanStatusCode.Error,
            'Hightouch run ${r.result!.runStatus}',
          );
        }
      }
      if (r.result!.queryRows != null) {
        extras.add(OTel.attributeInt(
          'hightouch.query.rows',
          r.result!.queryRows!,
        ));
      }
      if (r.result!.addedRows != null) {
        extras.add(OTel.attributeInt(
          'hightouch.added.rows',
          r.result!.addedRows!,
        ));
      }
      if (r.result!.changedRows != null) {
        extras.add(OTel.attributeInt(
          'hightouch.changed.rows',
          r.result!.changedRows!,
        ));
      }
      if (r.result!.removedRows != null) {
        extras.add(OTel.attributeInt(
          'hightouch.removed.rows',
          r.result!.removedRows!,
        ));
      }
      if (r.result!.rejectedRows != null) {
        extras.add(OTel.attributeInt(
          'hightouch.rejected.rows',
          r.result!.rejectedRows!,
        ));
      }
      if (r.result!.attemptCount != null) {
        extras.add(OTel.attributeInt(
          'hightouch.attempt.count',
          r.result!.attemptCount!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Hightouch HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
