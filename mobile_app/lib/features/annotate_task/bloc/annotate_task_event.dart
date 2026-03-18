part of 'annotate_task_bloc.dart';

class AnnotateTaskEvent {}

class LoadAnnotateTaskEvent extends AnnotateTaskEvent {}

class CreateAnnotateTaskEvent extends AnnotateTaskEvent {
  final AnnotateAssetModel asset;
  CreateAnnotateTaskEvent({required this.asset});
}

class PublishAnnotateTaskEvent extends AnnotateTaskEvent {
  final AnnotateTaskModel task;
  PublishAnnotateTaskEvent({required this.task});
}

class DeleteAnnotateTaskEvent extends AnnotateTaskEvent {
  final String id;
  DeleteAnnotateTaskEvent({required this.id});
}
