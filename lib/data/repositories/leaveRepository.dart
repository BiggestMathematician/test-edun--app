import 'package:dio/dio.dart';
import 'package:eschool/data/models/leaveDetails.dart';
import 'package:eschool/data/models/leaveRequest.dart';
import 'package:eschool/data/models/leaveSettings.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/constants.dart';

class LeaveRepository {
  Future<List<LeaveDetails>> getLeaves(
      {required LeaveDayType leaveDayType}) async {
    try {
      final result = await Api.get(url: Api.getLeaves, queryParameters: {
        "type": getLeaveDayTypeStatus(leaveDayType: leaveDayType)
      }, useAuthToken: true);

      return ((result['data'] ?? []) as List)
          .map((leaveDetails) =>
              LeaveDetails.fromJson(Map.from(leaveDetails ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final result = await Api.get(url: Api.getLeaveRequests, useAuthToken: true);

      return ((result['data'] ?? []) as List)
          .map((leaveRequest) =>
              LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> approveOrRejectLeaveRequest(
      {required int leaveRequestId, required int status}) async {
    try {
      await Api.post(
          url: Api.approveOrRejectLeaveRequest,
          body: {"leave_id": leaveRequestId, "status": status}, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> applyLeave(
      {required String reason,
      required List<Map<String, String>> leaves,
      List<String>? attachmentPaths}) async {
    try {
      List<MultipartFile> attachments = [];

      for (var attachmentPath in attachmentPaths ?? []) {
        attachments.add(await MultipartFile.fromFile(attachmentPath));
      }

      await Api.post(url: Api.applyLeave, body: {
        "reason": reason,
        "leave_details": leaves,
        "files": attachments,
      }, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> submitTask({
    required String name,
    required String duration,
    required DateTime endDate,
  }) async {
    try {
      //print({"name": name, "end_date": endDate});
      await Api.post(url: Api.addTasks, body: {
        "name": name,
        "end_date": endDate,
        "duration": duration
      }, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> submitEditeTask({
    required String name,
    required String id,
    required String duration,
    required DateTime endDate,
  }) async {
    try {
      //print({"name": name, "end_date": endDate});
      await Api.post(url: Api.updateTask, body: {
        "name": name,
        "id": id,
        "duration": duration,
        "end_date": endDate,
      }, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }


  Future<
          ({
            List<LeaveRequest> leaves,
            double takenLeaves,
            double monthlyAllowedLeaves
          })>
      getUserLeaves(
          {required int sessionYearId,
          int? monthNumber,
          required int userId}) async {
    try {
      final result = await Api.get(url: Api.getUserLeaves, queryParameters: {
        "session_year_id": sessionYearId,
        "staff_id": userId,
        "month": monthNumber
      }, useAuthToken: true);

      return (
        leaves: ((result['data']['leave_details'] ?? []) as List)
            .map((leaveRequest) =>
                LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
            .toList(),
        takenLeaves: double.parse((result['data']['taken_leaves']).toString()),
        monthlyAllowedLeaves:
            double.parse((result['data']['monthly_allowed_leaves']).toString()),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<LeaveSettings> getLeaveSettings() async {
    try {
      final result = await Api.get(url: Api.getLeaveSettings, useAuthToken: true);
      final dataList = (result['data'] as List);

      return dataList.isEmpty
          ? LeaveSettings.fromJson({})
          : LeaveSettings.fromJson(Map.from(dataList.first ?? {}));
    } catch (e, _) {
      throw ApiException(e.toString());
    }
  }
}
