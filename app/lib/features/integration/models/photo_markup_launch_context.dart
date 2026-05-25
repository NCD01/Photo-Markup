class PhotoMarkupLaunchContext {
  const PhotoMarkupLaunchContext({
    this.launchedFromControlCenter = false,
    this.clientId,
    this.clientName,
    this.projectId,
    this.projectCode,
    this.sourceImagePath,
    this.suggestedExportFolder,
    this.suggestedEditableMarkupFolder,
    this.returnMode,
    this.sourceLabel,
  });

  final bool launchedFromControlCenter;
  final String? clientId;
  final String? clientName;
  final String? projectId;
  final String? projectCode;
  final String? sourceImagePath;
  final String? suggestedExportFolder;
  final String? suggestedEditableMarkupFolder;
  final String? returnMode;
  final String? sourceLabel;

  bool get hasAnyContext =>
      launchedFromControlCenter ||
      clientId != null ||
      clientName != null ||
      projectId != null ||
      projectCode != null ||
      sourceImagePath != null ||
      suggestedExportFolder != null ||
      suggestedEditableMarkupFolder != null ||
      returnMode != null ||
      sourceLabel != null;

  PhotoMarkupLaunchContext copyWith({
    bool? launchedFromControlCenter,
    String? clientId,
    String? clientName,
    String? projectId,
    String? projectCode,
    String? sourceImagePath,
    String? suggestedExportFolder,
    String? suggestedEditableMarkupFolder,
    String? returnMode,
    String? sourceLabel,
  }) {
    return PhotoMarkupLaunchContext(
      launchedFromControlCenter:
          launchedFromControlCenter ?? this.launchedFromControlCenter,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      projectId: projectId ?? this.projectId,
      projectCode: projectCode ?? this.projectCode,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      suggestedExportFolder:
          suggestedExportFolder ?? this.suggestedExportFolder,
      suggestedEditableMarkupFolder:
          suggestedEditableMarkupFolder ?? this.suggestedEditableMarkupFolder,
      returnMode: returnMode ?? this.returnMode,
      sourceLabel: sourceLabel ?? this.sourceLabel,
    );
  }
}

class LaunchContextBootstrap {
  const LaunchContextBootstrap({
    this.launchContext,
    this.initialImagePath,
    this.launchErrorMessage,
  });

  final PhotoMarkupLaunchContext? launchContext;
  final String? initialImagePath;
  final String? launchErrorMessage;
}
