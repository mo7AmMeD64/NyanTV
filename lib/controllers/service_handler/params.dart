class SearchParams {
  String query;
  Map<String, dynamic>? filters;
  dynamic args;

  SearchParams({
    required this.query,
    this.isManga = false,
    this.filters,
    this.args,
  });
}

class FetchDetailsParams {
  dynamic id;

  FetchDetailsParams({
    required this.id,
    this.isManga = false,
  });
}



class UpdateListEntryParams {
  String listId;
  List<String>? syncIds;
  double? score;
  String? status;
  int? progress;
  bool isAnime;

  UpdateListEntryParams({
    required this.listId,
    this.syncIds,
    this.score,
    this.status,
    this.progress,
    this.isAnime = true,
  });
}
