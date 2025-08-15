import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/leaveRepository.dart';

abstract class ApplyLeaveState {}

class ApplyLeaveInitial extends ApplyLeaveState {}

class ApplyLeaveInProgress extends ApplyLeaveState {}

class ApplyLeaveSuccess extends ApplyLeaveState {}

class ApplyLeaveFailure extends ApplyLeaveState {
  final String errorMessage;

  ApplyLeaveFailure(this.errorMessage);
}

class ApplyLeaveCubit extends Cubit<ApplyLeaveState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  ApplyLeaveCubit() : super(ApplyLeaveInitial());

  void applyLeave(
      {required String reason,
      required Map<DateTime, String> leaveDays,
      List<String>? attachmentPaths}) async {
    try {
      List<Map<String, String>> leaveDetails = [];

      for (var leaveDay in leaveDays.keys) {
        leaveDetails.add({
          "type": "",
          "date": "${leaveDay.year}-${leaveDay.month}-${leaveDay.day}"
        });
      }
      emit(ApplyLeaveInProgress());
      await _leaveRepository.applyLeave(
        leaves: leaveDetails,
        reason: reason,
        attachmentPaths: attachmentPaths,
      );
      emit(ApplyLeaveSuccess());
    } catch (e) {
      emit(ApplyLeaveFailure(e.toString()));
    }
  }

  void submitTask(
      {required String name,
      required String duration,
      required DateTime endDate}) async {
    try {

      emit(ApplyLeaveInProgress());
      await _leaveRepository.submitTask(
        endDate: endDate,
        name: name,
        duration: duration
      );
      emit(ApplyLeaveSuccess());
    } catch (e) {
      emit(ApplyLeaveFailure(e.toString()));
    }
  }

  void submitEditeTask(
      {required String name,
      required String duration,
      required String id,
      required DateTime endDate}) async {
    try {

      emit(ApplyLeaveInProgress());
      await _leaveRepository.submitEditeTask(
        endDate: endDate,
        name: name,
        duration: duration,
        id: id,
      );
      emit(ApplyLeaveSuccess());
    } catch (e) {
      emit(ApplyLeaveFailure(e.toString()));
    }
  }
}

