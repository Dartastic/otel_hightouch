// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_hightouch/otel_hightouch.dart';

/// Traces Hightouch calls with OpenTelemetry.
///
/// `otel_hightouch` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Hightouch call in
/// [tracedHightouch]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'hightouch-example');

  // Wraps a Hightouch API call in a CLIENT span.
  final hightouchId = await tracedHightouch<String>(
    operation: 'syncs.create',
    invoke: () async {
      // Make the Hightouch call here, then report what it returned.
      const id = 'hightouch_8f3a2c';
      return const HightouchCallResult(
          value: id,
          result: HightouchResult(
              workspaceId: 'workspace_8f3a2c',
              sourceSlug: 'snowflake',
              modelId: 'model_8f3a2c',
              modelName: 'standard',
              syncId: 'sync_8f3a2c',
              destinationSlug: 'salesforce',
              syncRunId: 'syncrun_8f3a2c',
              syncMode: 'upsert',
              runStatus: 'success',
              queryRows: 1,
              addedRows: 1,
              changedRows: 1,
              removedRows: 1,
              rejectedRows: 1,
              attemptCount: 3,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedHightouch syncs.create returned $hightouchId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutHightouchInstrumentationAsync.
  await runWithoutHightouchInstrumentationAsync(
    () => tracedHightouch<String>(
      operation: 'syncs.create',
      invoke: () async {
        const id = 'hightouch_8f3a2c';
        return const HightouchCallResult(
            value: id,
            result: HightouchResult(
                workspaceId: 'workspace_8f3a2c',
                sourceSlug: 'snowflake',
                modelId: 'model_8f3a2c',
                modelName: 'standard',
                syncId: 'sync_8f3a2c',
                destinationSlug: 'salesforce',
                syncRunId: 'syncrun_8f3a2c',
                syncMode: 'upsert',
                runStatus: 'success',
                queryRows: 1,
                addedRows: 1,
                changedRows: 1,
                removedRows: 1,
                rejectedRows: 1,
                attemptCount: 3,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
